package content

import (
	"testing"

	"github.com/google/uuid"
)

func TestAggregateUsesDurationWeighting(t *testing.T) {
	partnerRole := "dad"
	videos := []Video{
		{ID: uuid.New(), DurationSeconds: 100, Me: Activity{FurthestSeconds: 100, Completed: true}, Partner: &PartnerActivity{Role: partnerRole, FurthestSeconds: 50}},
		{ID: uuid.New(), DurationSeconds: 300, Me: Activity{FurthestSeconds: 0}, Partner: &PartnerActivity{Role: partnerRole, FurthestSeconds: 300, Completed: true, IsCurrentlyWatching: true}},
	}
	me, partner := aggregate(videos)
	if me.Percent != 25 || me.CompletedVideos != 1 {
		t.Fatalf("me aggregate = %#v", me)
	}
	if partner == nil || partner.Percent != 87 || partner.CompletedVideos != 1 || !partner.IsCurrentlyWatching {
		t.Fatalf("partner aggregate = %#v", partner)
	}
}

func TestPercentageCapsAtHundred(t *testing.T) {
	if got := percentage(150, 100); got != 100 {
		t.Fatalf("percentage = %d, want 100", got)
	}
}
