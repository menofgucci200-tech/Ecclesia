<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Saint extends Model
{
    protected $fillable = [
        'date',
        'feast',
        'name',
        'summary',
        'image_url',
        'wikipedia_url',
        'color',
        'liturgical_day',
        'source',
        'is_hidden',
    ];

    protected $casts = [
        'date' => 'date',
        'is_hidden' => 'boolean',
    ];

    /** Whether an actual saint (not just a feria) is celebrated. */
    public function hasSaint(): bool
    {
        return filled($this->name);
    }
}
