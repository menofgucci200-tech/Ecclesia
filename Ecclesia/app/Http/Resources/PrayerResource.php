<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Prayer;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Prayer
 */
class PrayerResource extends JsonResource
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
            'subtitle' => $this->subtitle,
            'body' => $this->body,
            'reference' => $this->reference,
            'image_url' => $this->image ? \Illuminate\Support\Facades\Storage::url($this->image) : null,
        ];
    }
}
