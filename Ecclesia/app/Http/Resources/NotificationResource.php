<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Announcement;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

/**
 * A parish announcement rendered as a notification-center entry: the same
 * feed content, plus a `read` flag derived from the requesting user's
 * `notifications_last_seen_at` watermark.
 *
 * @mixin Announcement
 */
class NotificationResource extends JsonResource
{
    public function __construct(Announcement $resource, private readonly ?Carbon $lastSeenAt)
    {
        parent::__construct($resource);
    }

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
            'is_important' => $this->is_important,
            'published_at' => $this->published_at?->toIso8601String(),
            'read' => $this->lastSeenAt !== null && $this->published_at !== null
                && $this->lastSeenAt->gte($this->published_at),
        ];
    }
}
