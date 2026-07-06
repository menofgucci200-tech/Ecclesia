<?php

declare(strict_types=1);

namespace App\Repositories\Contracts;

use App\Models\Parish;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ParishRepositoryInterface
{
    public function findById(int $id): ?Parish;

    public function findActiveById(int $id): ?Parish;

    /**
     * Paginated list of joinable parishes, optionally filtered by a search term
     * matching name, code, city, commune, region, diocese or address.
     *
     * @return LengthAwarePaginator<int, Parish>
     */
    public function paginateActive(?string $search, int $perPage): LengthAwarePaginator;
}
