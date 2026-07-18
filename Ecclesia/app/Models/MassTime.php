<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MassTime extends Model
{
    protected $fillable = [
        'parish_id',
        'day_of_week',
        'time',
        'label',
        'note',
        'sort_order',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'day_of_week' => 'integer',
            'sort_order' => 'integer',
        ];
    }

    /**
     * @return BelongsTo<Parish, $this>
     */
    public function parish(): BelongsTo
    {
        return $this->belongsTo(Parish::class);
    }

    /**
     * French day label, 0 = Sunday … 6 = Saturday.
     */
    public function dayLabel(): string
    {
        return [
            'Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi',
        ][$this->day_of_week] ?? '';
    }

    /**
     * The time formatted as HH:mm.
     */
    public function formattedTime(): string
    {
        return substr((string) $this->time, 0, 5);
    }
}
