<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Liturgy;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Liturgy
 */
class LiturgyResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $gospel = $this->gospel();

        return [
            'date' => $this->date->toDateString(),
            'liturgical_day' => $this->liturgical_day,
            'season' => $this->season,
            'color' => $this->color,
            'week' => $this->week,
            'gospel' => $gospel === null ? null : [
                'ref' => $gospel['ref'] ?? null,
                'title' => $gospel['title'] ?? null,
            ],
            'readings' => array_values($this->readings ?? []),
        ];
    }
}
