<?php

declare(strict_types=1);

namespace App\Services;

use App\Exceptions\ParishNotFoundException;
use App\Models\Parish;
use App\Repositories\Contracts\ParishRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ParishService
{
    public function __construct(
        private readonly ParishRepositoryInterface $parishes,
    ) {}

    /**
     * Paginated list of joinable parishes, optionally filtered by a search term.
     *
     * @return LengthAwarePaginator<int, Parish>
     */
    public function paginate(?string $search, int $perPage): LengthAwarePaginator
    {
        return $this->parishes->paginateActive($search, $perPage);
    }

    /**
     * Resolve a joinable parish by id or fail.
     *
     * @throws ParishNotFoundException
     */
    public function findActiveOrFail(int $id): Parish
    {
        $parish = $this->parishes->findActiveById($id);

        if ($parish === null) {
            throw new ParishNotFoundException;
        }

        return $parish;
    }
}
