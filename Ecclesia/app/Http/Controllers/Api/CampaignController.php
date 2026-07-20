<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Campaign;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CampaignController extends Controller
{
    /**
     * Active fundraising campaigns of the faithful's parish.
     */
    public function index(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if ($user->parish_id === null) {
            return response()->json(['campaigns' => []]);
        }

        $campaigns = Campaign::query()
            ->where('parish_id', $user->parish_id)
            ->where('is_active', true)
            ->latest()
            ->get()
            ->map(fn (Campaign $c) => $this->present($c));

        return response()->json(['campaigns' => $campaigns]);
    }

    /**
     * Record a pledge (promise of donation) — no real payment yet.
     */
    public function pledge(Request $request, Campaign $campaign): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($campaign->parish_id === $user->parish_id && $campaign->is_active, 404);

        $validated = $request->validate([
            'amount' => ['required', 'integer', 'min:100', 'max:100000000'],
        ]);

        $campaign->pledges()->create([
            'user_id' => $user->id,
            'amount' => $validated['amount'],
            'status' => 'pledged',
        ]);

        // Reflect the pledge in the running total straight away.
        $campaign->increment('collected_amount', $validated['amount']);

        return response()->json(['campaign' => $this->present($campaign->fresh())]);
    }

    /**
     * @return array<string, mixed>
     */
    private function present(Campaign $c): array
    {
        return [
            'id' => $c->id,
            'title' => $c->title,
            'description' => $c->description,
            'type' => $c->type,
            'type_label' => $c->typeLabel(),
            'target_amount' => $c->target_amount,
            'collected_amount' => $c->collected_amount,
            'progress' => $c->progress(),
            'image_url' => $c->image ? Storage::url($c->image) : null,
            'ends_at' => optional($c->ends_at)->toDateString(),
        ];
    }
}
