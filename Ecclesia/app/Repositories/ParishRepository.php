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
}
