package fs_content

import (
	"io/ioutil"
	"log"

	"gopkg.in/yaml.v3"
)

// Could have done it in generics if 1.18 was supported in GCF
// Panics on error
func loadLearningPathInfo(path string) (info learningPathInfo) {
	buf, err := ioutil.ReadFile(path)
	if err != nil {
		log.Panic(err)
	}

	err = yaml.Unmarshal(buf, &info)
	if err != nil {
		log.Panic(err)
	}

	return info
}

func loadLearningModuleInfo(path string) (info learningModuleInfo) {
	buf, err := ioutil.ReadFile(path)
	if err != nil {
		log.Panic(err)
	}

	err = yaml.Unmarshal(buf, &info)
	if err != nil {
		log.Panic(err)
	}

	return info
}

func loadLearningUnitInfo(path string) (info learningUnitInfo) {
	buf, err := ioutil.ReadFile(path)
	if err != nil {
		log.Panic(err)
	}

	err = yaml.Unmarshal(buf, &info)
	if err != nil {
		log.Panic(err)
	}

	return info
}
