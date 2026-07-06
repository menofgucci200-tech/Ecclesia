<?php

declare(strict_types=1);

namespace App\Http\Requests\Auth;

use App\Http\Requests\Concerns\NormalizesPhone;
use App\Rules\IvorianPhoneNumber;
use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    use NormalizesPhone;

    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->normalizePhoneInput();
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'phone' => ['required', 'string', app(IvorianPhoneNumber::class)],
            'password' => ['required', 'string'],
        ];
    }

    public function phoneNumber(): string
    {
        return (string) $this->string('phone');
    }

    public function password(): string
    {
        return (string) $this->string('password');
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'phone' => 'numéro de téléphone',
            'password' => 'mot de passe',
        ];
    }
}
