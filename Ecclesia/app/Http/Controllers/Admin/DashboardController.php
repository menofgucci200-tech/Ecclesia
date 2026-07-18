<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\Parish;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\View\View;

class DashboardController extends Controller
{
    /**
     * Render the dashboard home with headline metrics and recent activity.
     */
    public function index(): View
    {
        /** @var User $admin */
        $admin = auth()->user();
        $parishId = $admin->managedParishId(); // null => platform-wide

        $membersQuery = User::query()->where('role', UserRole::Member->value);
        $announcementsQuery = Announcement::query();

        if ($parishId !== null) {
            $membersQuery->where('parish_id', $parishId);
            $announcementsQuery->where('parish_id', $parishId);
        }

        // ---- Headline metrics --------------------------------------------
        $totalMembers = (clone $membersQuery)->count();
        $activeMembers = (clone $membersQuery)->where('status', UserStatus::Active->value)->count();
        $newThisMonth = (clone $membersQuery)->where('created_at', '>=', now()->startOfMonth())->count();

        $totalAnnouncements = (clone $announcementsQuery)->count();
        $publishedAnnouncements = (clone $announcementsQuery)->whereNotNull('published_at')->where('published_at', '<=', now())->count();

        $totalParishes = Parish::query()->count();
        $activeParishes = Parish::query()->where('status', 'active')->count();

        // ---- Members joined over the last 6 months (chart) ---------------
        $growth = $this->membersByMonth($parishId);

        // ---- Recent activity ---------------------------------------------
        $recentMembers = (clone $membersQuery)
            ->with('parish:id,name,commune')
            ->latest('created_at')
            ->limit(6)
            ->get();

        $recentAnnouncements = $announcementsQuery
            ->with('parish:id,name')
            ->latest('published_at')
            ->limit(5)
            ->get();

        // Members grouped by parish (super admin only, top parishes).
        $membersByParish = $parishId === null
            ? Parish::query()
                ->withCount(['members as members_count' => fn ($q) => $q->where('role', UserRole::Member->value)])
                ->orderByDesc('members_count')
                ->limit(6)
                ->get()
            : collect();

        return view('admin.dashboard', [
            'admin' => $admin,
            'scopeParish' => $parishId !== null ? Parish::find($parishId) : null,
            'totalMembers' => $totalMembers,
            'activeMembers' => $activeMembers,
            'newThisMonth' => $newThisMonth,
            'totalAnnouncements' => $totalAnnouncements,
            'publishedAnnouncements' => $publishedAnnouncements,
            'totalParishes' => $totalParishes,
            'activeParishes' => $activeParishes,
            'growth' => $growth,
            'recentMembers' => $recentMembers,
            'recentAnnouncements' => $recentAnnouncements,
            'membersByParish' => $membersByParish,
        ]);
    }

    /**
     * Count of members who joined per month over the last 6 months.
     *
     * @return array{labels: list<string>, values: list<int>}
     */
    private function membersByMonth(?int $parishId): array
    {
        $labels = [];
        $values = [];
        $months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];

        for ($i = 5; $i >= 0; $i--) {
            $start = now()->startOfMonth()->subMonths($i);
            $end = (clone $start)->endOfMonth();

            $query = User::query()
                ->where('role', UserRole::Member->value)
                ->whereBetween('created_at', [$start, $end]);

            if ($parishId !== null) {
                $query->where('parish_id', $parishId);
            }

            $labels[] = $months[$start->month - 1];
            $values[] = $query->count();
        }

        return ['labels' => $labels, 'values' => $values];
    }
}
