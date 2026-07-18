<?php

declare(strict_types=1);

namespace App\Http\Requests\Admin;

use App\Enums\AnnouncementCategory;
use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AnnouncementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null && $this->user()->isStaff();
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var User $user */
        $user = $this->user();
        $scopeParishId = $user->managedParishId();

        return [
            // Parish admins are locked to their parish; super admins pick one.
            'parish_id' => $scopeParishId !== null
                ? ['nullable']
                : ['required', 'integer', Rule::exists('parishes', 'id')],
            'category' => ['required', Rule::in(AnnouncementCategory::values())],
            'title' => ['required', 'string', 'max:255'],
            'body' => ['required', 'string'],
            'image_url' => ['nullable', 'url', 'max:2048'],
            'video_url' => ['nullable', 'url', 'max:2048'],
            'author_name' => ['required', 'string', 'max:255'],
            'author_role' => ['nullable', 'string', 'max:255'],
            'is_pinned' => ['boolean'],
            'is_important' => ['boolean'],
            'published_at' => ['nullable', 'date'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'parish_id' => 'paroisse', 'category' => 'catégorie', 'title' => 'titre',
            'body' => 'contenu', 'image_url' => 'image', 'video_url' => 'vidéo',
            'author_name' => 'auteur', 'author_role' => 'rôle', 'published_at' => 'date de publication',
        ];
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'is_pinned' => $this->boolean('is_pinned'),
            'is_important' => $this->boolean('is_important'),
        ]);
    }
}
