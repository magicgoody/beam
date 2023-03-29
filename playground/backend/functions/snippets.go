package functions

import (
	"beam.apache.org/playground/backend/internal/db/datastore"
	"beam.apache.org/playground/backend/internal/utils"
	"context"
	"fmt"
	"net/http"
	"time"

	"beam.apache.org/playground/backend/internal/db/mapper"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	fmt.Printf("Initializing snippets functions\n")

	functions.HTTP("cleanupSnippets", cleanupSnippets)
	functions.HTTP("deleteObsoleteSnippets", deleteObsoleteSnippets)
	functions.HTTP("incrementSnippetViews", incrementSnippetViews)
}

// cleanupSnippets removes old snippets from the database.
func cleanupSnippets(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	env := GetEnvironment()

	ctx := context.Background()
	pcMapper := mapper.NewPrecompiledObjectMapper()
	db, err := datastore.New(ctx, pcMapper, nil, env.GetProjectId())
	if err != nil {
		//TODO: figure out how to use existing logger
		fmt.Printf("Couldn't create the database client, err: %s\n", err.Error())
		// Return 500 error
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	//TODO: read it form properties.yaml (or from query?)
	retentionPeriod := 60 * time.Hour * 24

	err = db.DeleteUnusedSnippets(ctx, retentionPeriod)
	if err != nil {
		fmt.Printf("Couldn't delete unused code snippets, err: %s \n", err.Error())
		// Return 500 error and error message
		w.WriteHeader(http.StatusInternalServerError)
		_, werr := w.Write([]byte(err.Error()))
		if werr != nil {
			fmt.Printf("Couldn't write error message, err: %s \n", werr.Error())
		}
		return
	}

	w.WriteHeader(http.StatusOK)
}

func deleteObsoleteSnippets(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	env := GetEnvironment()

	ctx := context.Background()
	pcMapper := mapper.NewPrecompiledObjectMapper()
	db, err := datastore.New(ctx, pcMapper, nil, env.GetProjectId())
	if err != nil {
		//TODO: figure out how to use existing logger
		fmt.Printf("Couldn't create the database client, err: %s\n", err.Error())
		// Return 500 error
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	snipId := r.URL.Query().Get("snipId")
	persistenceKey := r.URL.Query().Get("persistenceKey")

	snipKey := utils.GetSnippetKey(ctx, snipId)
	err = db.DeleteObsoleteSnippets(ctx, snipKey, persistenceKey)
	if err != nil {
		fmt.Printf("Couldn't delete obsolete code snippets for snipId %s, persistenceKey %s, err: %s \n", snipId, persistenceKey, err.Error())
		// Return 500 error and error message
		w.WriteHeader(http.StatusInternalServerError)
		_, werr := w.Write([]byte(err.Error()))
		if werr != nil {
			fmt.Printf("Couldn't write error message, err: %s \n", werr.Error())
		}
		return
	}

	w.WriteHeader(http.StatusOK)
}

func incrementSnippetViews(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	env := GetEnvironment()

	ctx := context.Background()
	pcMapper := mapper.NewPrecompiledObjectMapper()
	db, err := datastore.New(ctx, pcMapper, nil, env.GetProjectId())
	if err != nil {
		//TODO: figure out how to use existing logger
		fmt.Printf("Couldn't create the database client, err: %s\n", err.Error())
		// Return 500 error
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	snipId := r.URL.Query().Get("snipId")

	err = db.IncrementSnippetVisitorsCount(ctx, snipId)
	if err != nil {
		fmt.Printf("Couldn't increment snippet visitors count for snipId %s, err: %s \n", snipId, err.Error())
		// Return 500 error and error message
		w.WriteHeader(http.StatusInternalServerError)
		_, werr := w.Write([]byte(err.Error()))
		if werr != nil {
			fmt.Printf("Couldn't write error message, err: %s \n", werr.Error())
		}
		return
	}
}
