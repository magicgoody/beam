package functions

import "net/http"

// Middleware to check http method.
func EnsureMethod(method string) func(http.HandlerFunc) http.HandlerFunc {
	return func(next http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			if r.Method == method {
				next(w, r)
			} else {
				w.WriteHeader(http.StatusMethodNotAllowed)
			}
		}
	}
}
