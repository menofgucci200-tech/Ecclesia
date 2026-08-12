<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Saint;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Http;

/**
 * Builds the "Saint of the day" from AELF (feast name) enriched with a short
 * biography and image from the French Wikipedia. Results are cached per date
 * in the `saints` table and remain editable by a super-admin.
 */
class SaintService
{
    public function __construct(private readonly AelfService $aelf)
    {
    }

    public const DEFAULT_ZONE = 'afrique';

    public function forDate(Carbon $date, string $zone = self::DEFAULT_ZONE): ?Saint
    {
        $saint = Saint::query()->whereDate('date', $date->toDateString())->first();

        return $saint ?? $this->sync($date, $zone);
    }

    public function visibleForDate(Carbon $date, string $zone = self::DEFAULT_ZONE): ?Saint
    {
        $saint = $this->forDate($date, $zone);

        return ($saint && ! $saint->is_hidden) ? $saint : null;
    }

    public function sync(Carbon $date, string $zone = self::DEFAULT_ZONE): ?Saint
    {
        $existing = Saint::query()->whereDate('date', $date->toDateString())->first();

        // Never overwrite an entry a super-admin edited by hand.
        if ($existing !== null && $existing->source === 'manual') {
            return $existing;
        }

        $info = $this->aelf->fetchInformations($date->toDateString(), $zone);
        if ($info === null) {
            return $existing;
        }

        ['feast' => $feast, 'name' => $name] = $this->extractName($info);

        $payload = [
            'date' => $date->toDateString(),
            'feast' => $feast,
            'name' => $name,
            'color' => $info['couleur'] ?? null,
            'liturgical_day' => $info['ligne1'] ?? ($info['jour_liturgique_nom'] ?? null),
            'source' => 'aelf',
        ];

        if ($name !== null) {
            $wiki = $this->resolveWikipedia($name);
            $payload['summary'] = $wiki['summary'] ?? null;
            $payload['image_url'] = $wiki['image'] ?? null;
            $payload['wikipedia_url'] = $wiki['url'] ?? null;
        }

        return Saint::updateOrCreate(['date' => $date->toDateString()], $payload);
    }

    /**
     * Choose the celebration label + a searchable saint name from the AELF
     * fields. Feasts carry the name in `jour_liturgique_nom` (fete = the
     * degree word); optional memorials carry it in `fete`.
     *
     * @param  array<string, mixed>  $info
     * @return array{feast: ?string, name: ?string}
     */
    private function extractName(array $info): array
    {
        $fete = trim((string) ($info['fete'] ?? ''));
        $jour = trim((string) ($info['jour_liturgique_nom'] ?? ''));

        $candidate = $this->looksLikeSaint($fete) ? $fete
            : ($this->looksLikeSaint($jour) ? $jour : null);

        if ($candidate === null) {
            return ['feast' => null, 'name' => null];
        }

        return ['feast' => $candidate, 'name' => $this->cleanName($candidate)];
    }

    /** True when a label names a saint (not a degree word / feria / Sunday). */
    private function looksLikeSaint(string $label): bool
    {
        $label = trim($label);
        if ($label === '') {
            return false;
        }
        $low = mb_strtolower($label);
        $degrees = ['fête', 'fete', 'mémoire', 'memoire', 'mémoire facultative', 'solennité', 'solennite', 'férie', 'ferie'];
        if (in_array($low, $degrees, true)) {
            return false;
        }

        return ! preg_match(
            '/(^de la |^du |^de l\'|férie|dimanche|semaine du temps|temps ordinaire|temps pascal|de l\'avent|de carême|de careme|de noël|de noel|octave|cendres|semaine sainte|psautier)/iu',
            $low
        );
    }

    /** Reduce a label to a bare saint name ("S. Charbel Maklouf, prêtre" → "Charbel Maklouf"). */
    private function cleanName(string $label): ?string
    {
        $name = trim(explode(',', $label)[0]);
        $name = preg_replace(
            '/^(s\.|st\.?|ste\.?|bx\.?|bse\.?|bhx\.?|saint(e)?|bienheureux(se)?|bienheureuse)\s+/iu',
            '',
            $name
        );
        $name = trim((string) $name);

        return $name !== '' ? $name : null;
    }

    /**
     * @return array{summary: ?string, image: ?string, url: ?string}
     */
    private function resolveWikipedia(string $name): array
    {
        $empty = ['summary' => null, 'image' => null, 'url' => null];

        try {
            // 1) Try the page title directly (follows redirects).
            $direct = $this->fetchSummary($name);
            if ($direct !== null) {
                return $direct;
            }

            // A single, generic first name (e.g. "Marthe") too easily matches an
            // unrelated modern person in full-text search — only trust an exact
            // page for those. Multi-word names are safe to search.
            if (! preg_match('/[\s\-]/u', trim($name))) {
                return $empty;
            }

            // 2) Fall back to a full-text search, keeping the first result whose
            //    title actually shares a meaningful word with the saint's name
            //    (guards against irrelevant top hits).
            $search = Http::withHeaders(['User-Agent' => self::UA])
                ->timeout(20)
                ->get('https://fr.wikipedia.org/w/api.php', [
                    'action' => 'query', 'list' => 'search', 'srsearch' => $name,
                    'srlimit' => 5, 'format' => 'json',
                ]);

            foreach ($search->json('query.search') ?? [] as $hit) {
                $title = $hit['title'] ?? null;
                if ($title !== null && $this->titlesRelated($name, $title)) {
                    $summary = $this->fetchSummary($title);
                    if ($summary !== null) {
                        return $summary;
                    }
                }
            }

            return $empty;
        } catch (\Throwable) {
            return $empty;
        }
    }

    private const UA = 'EcclesiaApp/1.0 (paroisse; contact@ecclesia.app)';

    /**
     * Fetch a Wikipedia summary; null unless it is a real (standard) article.
     *
     * @return array{summary: ?string, image: ?string, url: ?string}|null
     */
    private function fetchSummary(string $title): ?array
    {
        $response = Http::withHeaders(['User-Agent' => self::UA])
            ->timeout(20)
            ->get('https://fr.wikipedia.org/api/rest_v1/page/summary/'.rawurlencode($title));

        if (! $response->successful() || $response->json('type') !== 'standard') {
            return null;
        }

        return [
            'summary' => $response->json('extract'),
            'image' => $response->json('thumbnail.source'),
            'url' => $response->json('content_urls.desktop.page'),
        ];
    }

    /** Whether a candidate title shares a significant word with the name. */
    private function titlesRelated(string $name, string $title): bool
    {
        $fold = static fn (string $s): array => array_filter(
            preg_split('/[\s\-\']+/u', mb_strtolower(strtr($s, 'àâäéèêëîïôöûüç', 'aaaeeeeiioouuc'))) ?: [],
            static fn (string $w): bool => mb_strlen($w) >= 4
        );

        $nameWords = $fold($name);
        $titleWords = $fold($title);

        return count(array_intersect($nameWords, $titleWords)) > 0;
    }
}
