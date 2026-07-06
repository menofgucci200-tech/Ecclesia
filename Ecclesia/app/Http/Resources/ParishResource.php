<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Parish;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Parish
 */
class ParishResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'code' => $this->code,
            'diocese' => $this->diocese,
            'address' => $this->address,
            'city' => $this->city,
            'commune' => $this->commune,
            'region' => $this->region,
            'country' => $this->country,
            'phone' => $this->phone,
            'email' => $this->email,
            'logo' => $this->logo,
            'status' => $this->status->value,
        ];
    }
}
