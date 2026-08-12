<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Models\Parish;
use App\Repositories\Contracts\ParishRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ParishRepository implements ParishRepositoryInterface
{
    public function findById(int $id): ?Parish
    {
        return Parish::query()->find($id);
    }

    public function findActiveById(int $id): ?Parish
    {
        return Parish::query()->active()->whereKey($id)->first();
    }

    public function paginateActive(?string $search, int $perPage): LengthAwarePaginator
    {
        return Parish::query()
            ->active()
            ->when(
                $search !== null && $search !== '',
                fn ($query) => $query->search($search),
            )
            ->orderBy('name')
            ->paginate($perPage)
            ->withQueryString();
    }

    public function nearby(float $lat, float $lng, float $radiusKm): \Illuminate\Support\Collection
    {
        // Computed in PHP rather than raw SQL trig functions: a parish
        // directory is at most a few hundred rows, so there's no
        // performance reason to lean on the database here — and doing it
        // in PHP sidesteps any SQL-dialect/mode quirks of the host's MySQL.
        return Parish::query()
            ->active()
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->get()
            ->map(function (Parish $parish) use ($lat, $lng) {
                $parish->distance_km = $this->haversineKm($lat, $lng, (float) $parish->latitude, (float) $parish->longitude);

                return $parish;
            })
            ->filter(fn (Parish $parish) => $parish->distance_km <= $radiusKm)
            ->sortBy('distance_km')
            ->values();
    }

    private function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadiusKm = 6371;
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;

        return $earthRadiusKm * 2 * atan2(sqrt($a), sqrt(1 - $a));
    }
}
