@if (session('success'))
    <div x-data="{ show: true }" x-show="show" x-init="setTimeout(() => show = false, 5000)"
         class="mb-5 flex items-start gap-3 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
        <x-icon name="check" class="mt-0.5 h-5 w-5 shrink-0" />
        <p class="flex-1">{{ session('success') }}</p>
        <button @click="show = false" class="text-emerald-500 hover:text-emerald-700">&times;</button>
    </div>
@endif

@if (session('error'))
    <div class="mb-5 flex items-start gap-3 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
        <p class="flex-1">{{ session('error') }}</p>
    </div>
@endif

@if ($errors->any() && ! $errors->has('email'))
    <div class="mb-5 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
        <p class="font-semibold">Veuillez corriger les erreurs suivantes :</p>
        <ul class="mt-1 list-inside list-disc">
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif
