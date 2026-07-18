<?php

declare(strict_types=1);

namespace App\Http\Requests\Admin;

use App\Enums\ParishStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ParishRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null && $this->user()->isSuperAdmin();
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        $parishId = $this->route('parish')?->id;

        return [
            'name' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'max:30', Rule::unique('parishes', 'code')->ignore($parishId)],
            'diocese' => ['required', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'city' => ['nullable', 'string', 'max:255'],
            'commune' => ['nullable', 'string', 'max:255'],
            'region' => ['nullable', 'string', 'max:255'],
            'country' => ['nullable', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:30'],
            'email' => ['nullable', 'email', 'max:255'],
            'status' => ['required', Rule::in(ParishStatus::values())],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'name' => 'nom', 'code' => 'code', 'diocese' => 'diocèse',
            'address' => 'adresse', 'city' => 'ville', 'commune' => 'commune',
            'region' => 'région', 'country' => 'pays', 'phone' => 'téléphone',
            'email' => 'e-mail', 'status' => 'statut',
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->filled('code')) {
            $this->merge(['code' => strtoupper(trim((string) $this->input('code')))]);
        }
    }
}
