<?php

declare(strict_types=1);

namespace App\Http\Requests\Parish;

use Illuminate\Foundation\Http\FormRequest;

class SearchParishRequest extends FormRequest
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
            'q' => ['required', 'string', 'max:100'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:'.IndexParishRequest::MAX_PER_PAGE],
        ];
    }

    public function term(): string
    {
        return trim((string) $this->query('q', ''));
    }

    public function perPage(): int
    {
        $perPage = (int) $this->query('per_page', (string) IndexParishRequest::DEFAULT_PER_PAGE);

        return max(1, min($perPage, IndexParishRequest::MAX_PER_PAGE));
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'q' => 'recherche',
        ];
    }
}
