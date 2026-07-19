<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class LiturgicalEvent extends Model
{
    protected $fillable = [
        'date',
        'year',
        'name',
        'grade',
        'grade_label',
        'color',
        'season',
        'source',
        'is_hidden',
        'synced_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'date' => 'date',
            'grade' => 'integer',
            'is_hidden' => 'boolean',
            'synced_at' => 'datetime',
        ];
    }

    /**
     * @param  Builder<LiturgicalEvent>  $query
     * @return Builder<LiturgicalEvent>
     */
    public function scopeVisible(Builder $query): Builder
    {
        return $query->where('is_hidden', false);
    }
}
