<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Payment
 */
class PaymentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'reference' => $this->reference,
            'type' => $this->type->value,
            'type_label' => $this->type->label(),
            'label' => $this->label,
            'amount' => $this->amount,
            'currency' => $this->currency,
            'status' => $this->status->value,
            'status_label' => $this->status->label(),
            'channel' => $this->channel,
            'operator' => $this->operator,
            'payment_url' => $this->payment_url,
            'created_at' => $this->created_at?->toIso8601String(),
            'paid_at' => $this->paid_at?->toIso8601String(),
            'mass_intention' => $this->whenLoaded('massIntention', fn () => [
                'intention_type' => $this->massIntention?->intention_type?->value,
                'intention' => $this->massIntention?->intention,
                'mass_date' => $this->massIntention?->mass_date?->toDateString(),
                'status' => $this->massIntention?->status,
            ]),
        ];
    }
}
