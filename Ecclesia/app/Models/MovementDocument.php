<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MovementDocument extends Model
{
    protected $fillable = [
        'movement_id',
        'title',
        'file_path',
        'mime',
        'size',
    ];

    /**
     * @return BelongsTo<Movement, $this>
     */
    public function movement(): BelongsTo
    {
        return $this->belongsTo(Movement::class);
    }

    public function humanSize(): string
    {
        $bytes = (int) $this->size;
        if ($bytes <= 0) {
            return '';
        }
        $units = ['o', 'Ko', 'Mo', 'Go'];
        $i = (int) floor(log($bytes, 1024));
        $i = min($i, count($units) - 1);

        return round($bytes / (1024 ** $i), 1).' '.$units[$i];
    }
}
