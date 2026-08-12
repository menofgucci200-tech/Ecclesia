<?php

declare(strict_types=1);

namespace App\Http\Requests\Parish;

use Illuminate\Foundation\Http\FormRequest;

class NearbyParishRequest extends FormRequest
{
    public const DEFAULT_RADIUS_KM = 50;

    public const MAX_RADIUS_KM = 300;

    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
            'radius_km' => ['nullable', 'numeric', 'min:1', 'max:'.self::MAX_RADIUS_KM],
        ];
    }

    public function lat(): float
    {
        return (float) $this->query('lat');
    }

    public function lng(): float
    {
        return (float) $this->query('lng');
    }

    public function radiusKm(): float
    {
        $radius = (float) $this->query('radius_km', (string) self::DEFAULT_RADIUS_KM);

        return max(1, min($radius, self::MAX_RADIUS_KM));
    }
}
