<!DOCTYPE html>
<html lang="fr" class="h-full">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Connexion · Espace mouvement</title>
    <link rel="icon" type="image/png" href="{{ asset('images/logo.png') }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Merriweather:ital@0;1&display=swap" rel="stylesheet">
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="h-full font-sans">
<div class="flex min-h-full items-center justify-center px-6 py-12">
    <div class="w-full max-w-sm">
        <div class="mb-6 flex justify-center"><img src="{{ asset('images/logo.png') }}" alt="Ecclesia" class="h-24 w-auto"></div>
        <span class="mb-3 inline-flex items-center gap-1.5 rounded-full bg-[color:var(--color-navy)]/10 px-2.5 py-1 text-xs font-semibold text-[color:var(--color-navy)]">👥 Responsable de mouvement</span>
        <h1 class="text-2xl font-extrabold text-[color:var(--color-navy-dark)]">Bienvenue</h1>
        <p class="mt-1 text-sm text-[color:var(--color-ink-soft)]">Connectez-vous à l'espace de votre mouvement.</p>

        @if ($errors->has('email'))
            <div class="mt-5 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{{ $errors->first('email') }}</div>
        @endif

        <form method="POST" action="{{ route('mouvement.login.attempt') }}" class="mt-6 space-y-5">
            @csrf
            <div>
                <label for="email" class="field-label">Login</label>
                <input id="email" name="email" type="text" value="{{ old('email') }}" required autofocus autocapitalize="none" autocorrect="off" spellcheck="false" class="input" placeholder="login du mouvement">
            </div>
            <div>
                <label for="password" class="field-label">Mot de passe</label>
                <input id="password" name="password" type="password" required class="input" placeholder="••••••••">
            </div>
            <label class="flex items-center gap-2 text-sm text-[color:var(--color-ink-soft)]">
                <input type="checkbox" name="remember" class="h-4 w-4 rounded border-[color:var(--color-border-strong)] text-[color:var(--color-navy)]"> Rester connecté
            </label>
            <button type="submit" class="btn-primary w-full py-3">Se connecter</button>
        </form>
        <p class="mt-8 text-center text-xs text-[color:var(--color-ink-faint)]">© {{ date('Y') }} Ecclesia</p>
    </div>
</div>
</body>
</html>
