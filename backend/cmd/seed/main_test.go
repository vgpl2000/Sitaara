package main

import (
	"strings"
	"testing"
)

func TestContentSeedsMatchHostedCatalog(t *testing.T) {
	t.Parallel()

	masterclasses := contentSeeds()
	if len(masterclasses) != 2 {
		t.Fatalf("masterclasses = %d, want 2", len(masterclasses))
	}

	wantedCounts := []int{4, 5}
	seenPublicIDs := make(map[string]struct{})
	for index, masterclass := range masterclasses {
		if got := len(masterclass.videos); got != wantedCounts[index] {
			t.Errorf("masterclass %q videos = %d, want %d", masterclass.slug, got, wantedCounts[index])
		}
		for _, video := range masterclass.videos {
			if video.durationSeconds <= 0 {
				t.Errorf("video %q duration = %d, want positive", video.title, video.durationSeconds)
			}
			wantedPrefix := "sitaara/masterclasses/" + masterclass.slug + "/"
			if !strings.HasPrefix(video.mediaPublicID, wantedPrefix) {
				t.Errorf("video %q public ID = %q, want prefix %q", video.title, video.mediaPublicID, wantedPrefix)
			}
			if _, duplicate := seenPublicIDs[video.mediaPublicID]; duplicate {
				t.Errorf("duplicate media public ID %q", video.mediaPublicID)
			}
			seenPublicIDs[video.mediaPublicID] = struct{}{}
		}
	}

	if got := len(seenPublicIDs); got != 9 {
		t.Errorf("unique media public IDs = %d, want 9", got)
	}
}

func TestCloudinaryDeliveryURLs(t *testing.T) {
	t.Parallel()

	const cloudName = "example-cloud"
	const publicID = "sitaara/masterclasses/example/01-video"

	if got, want := videoURL(cloudName, publicID), "https://res.cloudinary.com/example-cloud/video/upload/sitaara/masterclasses/example/01-video.mp4"; got != want {
		t.Errorf("videoURL() = %q, want %q", got, want)
	}
	if got, want := videoPosterURL(cloudName, publicID), "https://res.cloudinary.com/example-cloud/video/upload/so_1,q_auto,f_jpg/sitaara/masterclasses/example/01-video.jpg"; got != want {
		t.Errorf("videoPosterURL() = %q, want %q", got, want)
	}
}
