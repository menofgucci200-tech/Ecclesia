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
        // Haversine formula, computed in SQL so filtering/sorting by distance
        // doesn't require pulling every parish into PHP.
        $distance = '(6371 * ACOS(LEAST(1, GREATEST(-1,
            COS(RADIANS(?)) * COS(RADIANS(latitude)) * COS(RADIANS(longitude) - RADIANS(?))
            + SIN(RADIANS(?)) * SIN(RADIANS(latitude))
        ))))';

        return Parish::query()
            ->active()
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->selectRaw('parishes.*, '.$distance.' as distance_km', [$lat, $lng, $lat])
            ->havingRaw($distance.' <= ?', [$lat, $lng, $lat, $radiusKm])
            ->orderBy('distance_km')
            ->get();
    }
}
