<?php

declare(strict_types=1);

namespace App\Http\Requests\Auth;

use App\Http\Requests\Concerns\NormalizesPhone;
use App\Rules\IvorianPhoneNumber;
use Illuminate\Foundation\Http\FormRequest;

class ResetPasswordRequest extends FormRequest
{
    use NormalizesPhone;

    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->normalizePhoneInput();

        if (is_string($this->input('code'))) {
            $this->merge(['code' => trim($this->input('code'))]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'phone' => ['required', 'string', app(IvorianPhoneNumber::class)],
            'code' => ['required', 'string', 'digits:6'],
            'password' => ['required', 'confirmed', 'string', 'min:4', 'max:255'],
        ];
    }

    public function phoneNumber(): string
    {
        return (string) $this->string('phone');
    }

    public function code(): string
    {
        return (string) $this->string('code');
    }

    public function newPassword(): string
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
            'code' => 'code',
            'password' => 'mot de passe',
        ];
    }
}
