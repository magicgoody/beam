package components

import (
	"beam.apache.org/playground/backend/internal/logger"
	"context"
	"fmt"
	"net/http"
)

type ExternalFunctions interface {
	// CleanupSnippets removes old snippets from the database.
	CleanupSnippets(ctx context.Context) error

	// DeleteObsoleteSnippets removes old snippets from the database.
	DeleteObsoleteSnippets(ctx context.Context, snipId string, persistenceKey string) error

	// IncrementSnippetViews increments the number of views for the snippet.
	IncrementSnippetViews(ctx context.Context, snipId string) error
}

const (
	// TODO: read this from configuration
	cleanupSnippetsFunctionsUrl        = "http://cleanup_snippets:8080/"
	deleteObsoleteSnippetsFunctionsUrl = "http://delete_obsolete_snippets:8080/"
	incrementSnippetViewsFunctionsUrl  = "http://increment_snippet_views:8080/"
)

type externalFunctionsComponent struct {
}

func NewExternalFunctionsComponent() ExternalFunctions {
	return &externalFunctionsComponent{}
}

func makePostRequest(ctx context.Context, requestUrl string) error {
	request, err := http.NewRequestWithContext(ctx, "POST", requestUrl, nil)
	if err != nil {
		logger.Errorf("makePostRequest(): Couldn't create the request, err: %s\n", err.Error())
		return err
	}

	resp, err := http.DefaultClient.Do(request)
	if err != nil {
		logger.Errorf("makePostRequest(): Couldn't make POST request to the %s, err: %s\n", requestUrl, err.Error())
		return err
	}

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("status code: %d", resp.StatusCode)
	}

	return nil
}

func (c *externalFunctionsComponent) CleanupSnippets(ctx context.Context) error {
	requestUrl := fmt.Sprintf("%s", cleanupSnippetsFunctionsUrl)

	if err := makePostRequest(ctx, requestUrl); err != nil {
		logger.Errorf("CleanupSnippets(): Couldn't cleanup snippets, err: %s\n", err.Error())
		return err
	}

	return nil
}

func (c *externalFunctionsComponent) DeleteObsoleteSnippets(ctx context.Context, snipId string, persistenceKey string) error {
	requestUrl := fmt.Sprintf("%s?snipId=%s&persistenceKey=%s", deleteObsoleteSnippetsFunctionsUrl, snipId, persistenceKey)

	if err := makePostRequest(ctx, requestUrl); err != nil {
		logger.Errorf("DeleteObsoleteSnippets(): Couldn't delete obsolete snippets, err: %s\n", err.Error())
		return err
	}

	return nil
}

func (c *externalFunctionsComponent) IncrementSnippetViews(ctx context.Context, snipId string) error {
	requestUrl := fmt.Sprintf("%s?snipId=%s", incrementSnippetViewsFunctionsUrl, snipId)

	if err := makePostRequest(ctx, requestUrl); err != nil {
		logger.Errorf("IncrementSnippetViews(): Couldn't increment snippet views, err: %s\n", err.Error())
		return err
	}

	return nil
}
