<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Parish;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

/**
 * A parish plotted on the "Découvrir" map.
 *
 * @mixin Parish
 */
class NearbyParishResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'address' => $this->address,
            'city' => $this->city,
            'commune' => $this->commune,
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'is_partner' => $this->is_partner,
            'logo_url' => $this->logo ? Storage::url($this->logo) : null,
            'distance_km' => round((float) $this->distance_km, 1),
        ];
    }
}
