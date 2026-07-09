<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Models\Announcement;
use App\Repositories\Contracts\AnnouncementRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class AnnouncementRepository implements AnnouncementRepositoryInterface
{
    public function paginateForParish(int $parishId, int $perPage): LengthAwarePaginator
    {
        return Announcement::query()
            ->forParish($parishId)
            ->published()
            ->orderByDesc('is_pinned')
            ->orderByDesc('published_at')
            ->paginate($perPage)
            ->withQueryString();
    }
}
