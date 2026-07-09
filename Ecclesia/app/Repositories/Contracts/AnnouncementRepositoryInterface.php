<?php

declare(strict_types=1);

namespace App\Repositories\Contracts;

use App\Models\Announcement;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface AnnouncementRepositoryInterface
{
    /**
     * Published feed for a parish, pinned items first then most recent.
     *
     * @return LengthAwarePaginator<int, Announcement>
     */
    public function paginateForParish(int $parishId, int $perPage): LengthAwarePaginator;
}
