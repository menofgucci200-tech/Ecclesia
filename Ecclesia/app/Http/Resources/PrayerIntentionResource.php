<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\PrayerIntention;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin PrayerIntention
 */
class PrayerIntentionResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'intention' => $this->intention,
            'author_name' => $this->displayName(),
            'is_anonymous' => $this->is_anonymous,
            'prayers_count' => $this->prayers_count,
            'has_prayed' => (bool) ($this->has_prayed ?? false),
            'is_mine' => (bool) ($this->is_mine ?? false),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
