<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\MassIntentionType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MassIntention extends Model
{
    protected $fillable = [
        'payment_id',
        'parish_id',
        'user_id',
        'intention_type',
        'intention',
        'mass_date',
        'note',
        'amount',
        'status',
    ];

    protected $casts = [
        'intention_type' => MassIntentionType::class,
        'mass_date' => 'date',
        'amount' => 'integer',
    ];

    /**
     * @return BelongsTo<Parish, $this>
     */
    public function parish(): BelongsTo
    {
        return $this->belongsTo(Parish::class);
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @return BelongsTo<Payment, $this>
     */
    public function payment(): BelongsTo
    {
        return $this->belongsTo(Payment::class);
    }
}
