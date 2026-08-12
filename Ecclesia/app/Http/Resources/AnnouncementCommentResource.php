<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\AnnouncementComment;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

/**
 * @mixin AnnouncementComment
 */
class AnnouncementCommentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $user = $this->user;

        return [
            'id' => $this->id,
            'body' => $this->body,
            'author_name' => $user?->fullName() ?? 'Un fidèle',
            'author_initials' => $this->initials($user?->first_name, $user?->last_name),
            'author_avatar_url' => $user?->avatar ? Storage::url($user->avatar) : null,
            'is_mine' => $request->user()?->id === $this->user_id,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }

    private function initials(?string $first, ?string $last): string
    {
        $a = $first !== null && $first !== '' ? mb_strtoupper(mb_substr($first, 0, 1)) : '';
        $b = $last !== null && $last !== '' ? mb_strtoupper(mb_substr($last, 0, 1)) : '';
        $initials = $a.$b;

        return $initials === '' ? '?' : $initials;
    }
}
