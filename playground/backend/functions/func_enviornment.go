package functions

import "os"

type Environment interface {
	GetProjectId() string
}

type environment struct {
	projectID string
}

func GetEnvironment() Environment {
	projectId := os.Getenv("GOOGLE_CLOUD_PROJECT")
	return &environment{
		projectID: projectId,
	}
}

func (e *environment) GetProjectId() string {
	return e.projectID
}
