<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Announcement;
use App\Repositories\Contracts\AnnouncementRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class AnnouncementService
{
    public function __construct(
        private readonly AnnouncementRepositoryInterface $announcements,
    ) {}

    /**
     * The parish feed, pinned items first then most recent.
     *
     * @return LengthAwarePaginator<int, Announcement>
     */
    public function feedForParish(int $parishId, int $perPage): LengthAwarePaginator
    {
        return $this->announcements->paginateForParish($parishId, $perPage);
    }
}
