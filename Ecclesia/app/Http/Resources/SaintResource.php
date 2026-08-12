<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Saint;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Saint
 */
class SaintResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'date' => $this->date->toDateString(),
            'feast' => $this->feast,
            'name' => $this->name,
            'summary' => $this->summary,
            'image_url' => $this->image_url,
            'wikipedia_url' => $this->wikipedia_url,
            'color' => $this->color,
            'liturgical_day' => $this->liturgical_day,
            'has_saint' => $this->hasSaint(),
        ];
    }
}
