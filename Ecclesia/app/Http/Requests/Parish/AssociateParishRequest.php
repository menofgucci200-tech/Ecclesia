<?php

declare(strict_types=1);

namespace App\Http\Requests\Parish;

use App\Enums\ParishStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AssociateParishRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'parish_id' => [
                'required',
                'integer',
                Rule::exists('parishes', 'id')->where('status', ParishStatus::Active->value),
            ],
        ];
    }

    public function parishId(): int
    {
        return (int) $this->integer('parish_id');
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'parish_id' => 'paroisse',
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'parish_id.exists' => 'Cette paroisse est introuvable.',
        ];
    }
}
