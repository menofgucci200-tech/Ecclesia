<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\MassTime;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin MassTime
 */
class MassTimeResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'day_of_week' => $this->day_of_week,
            'day_label' => $this->dayLabel(),
            'time' => $this->formattedTime(),
            'label' => $this->label,
            'note' => $this->note,
        ];
    }
}
