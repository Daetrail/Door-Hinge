package middleware

import (
	"Server/internal/handler"
	"context"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

// These comments make me feel like I'm AI but I wrote them and they help me remember what I wrote

// AuthMiddleware Creates a reusable auth middleware to be able to guard multiple routes
func AuthMiddleware(secret string) func(http.Handler) http.Handler {
	// The actual middleware function, next is the actual route that needs to be protected
	return func(next http.Handler) http.Handler {
		// Functionality of the middleware function
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Get token from header
			header := r.Header.Get("Authorization")
			if !strings.HasPrefix(header, "Bearer ") {
				handler.SendError(w, http.StatusUnauthorized, "unauthorised")
				return
			}

			// Verify token
			// https://pkg.go.dev/github.com/golang-jwt/jwt/v5#example-Parse-Hmac
			tokenStr := strings.TrimPrefix(header, "Bearer ")
			token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (any, error) {
				return []byte(secret), nil
			}, jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}))
			if err != nil || !token.Valid {
				handler.SendError(w, http.StatusUnauthorized, "unauthorised")
				return
			}

			// Put userID into context
			claims, ok := token.Claims.(jwt.MapClaims)
			if !ok {
				handler.SendError(w, http.StatusInternalServerError, "internal server error")
				return
			}
			userID := claims["userID"].(string)
			ctx := context.WithValue(r.Context(), "userID", userID)

			// Run the protected route
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}
