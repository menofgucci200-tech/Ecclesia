<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Announcement;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Announcement
 */
class AnnouncementResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'category' => $this->category->value,
            'category_label' => $this->category->label(),
            'title' => $this->title,
            'body' => $this->body,
            'image_url' => $this->image_url,
            'video_url' => $this->video_url,
            'author_name' => $this->author_name,
            'author_role' => $this->author_role,
            'author_initials' => $this->authorInitials(),
            'is_pinned' => $this->is_pinned,
            'is_important' => $this->is_important,
            'likes_count' => $this->likes_count,
            'comments_count' => $this->comments_count,
            'published_at' => $this->published_at?->toIso8601String(),
        ];
    }

    /**
     * Up to two uppercase initials derived from the author name (e.g. "PJ").
     */
    private function authorInitials(): string
    {
        $words = preg_split('/\s+/', trim((string) $this->author_name)) ?: [];
        $letters = array_map(
            static fn (string $word): string => mb_strtoupper(mb_substr($word, 0, 1)),
            array_slice(array_filter($words), 0, 2),
        );

        return implode('', $letters);
    }
}
