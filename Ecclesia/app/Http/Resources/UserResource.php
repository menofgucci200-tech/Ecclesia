<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin User
 */
class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'full_name' => $this->fullName(),
            'gender' => $this->gender->value,
            'gender_label' => $this->gender->label(),
            'phone' => $this->phone,
            'email' => $this->email,
            'avatar_url' => $this->avatar ? \Illuminate\Support\Facades\Storage::url($this->avatar) : null,
            'preferences' => $this->preferences ?? new \stdClass(),
            'status' => $this->status->value,
            'has_parish' => $this->hasParish(),
            'parish_id' => $this->parish_id,
            'parish_joined_at' => $this->parish_joined_at?->toIso8601String(),
            'parish' => ParishResource::make($this->whenLoaded('parish')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
