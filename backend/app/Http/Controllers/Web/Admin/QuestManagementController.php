<?php

namespace App\Http\Controllers\Web\Admin;

use App\Http\Controllers\Controller;
use App\Models\Quest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class QuestManagementController extends Controller
{
    public function index(): View
    {
        return view('admin.quests', [
            'quests' => Quest::query()->orderByDesc('id')->get(),
            'editingQuest' => $this->editingQuest(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'type' => ['required', 'string', 'max:50'],
            'mode' => ['required', 'string', 'max:30'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'points' => ['required', 'integer', 'min:0'],
            'unlock_radius_m' => ['required', 'numeric', 'min:1'],
            'accuracy_threshold_m' => ['required', 'numeric', 'min:1'],
            'qr_code' => ['nullable', 'string', 'max:120'],
            'instruction' => ['nullable', 'string'],
            'quiz_question' => ['nullable', 'string'],
            'quiz_options' => ['nullable', 'string'],
            'quiz_answer' => ['nullable', 'string', 'max:255'],
            'timer_seconds' => ['nullable', 'integer', 'min:10'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        Quest::query()->create([
            ...$validated,
            'quiz_options' => $this->decodeQuizOptions($validated['quiz_options'] ?? null),
            'status' => 'approach_to_unlock',
            'is_active' => (bool) ($validated['is_active'] ?? true),
            'timer_seconds' => (int) ($validated['timer_seconds'] ?? 60),
        ]);

        return back()->with('success', 'Quest point berhasil ditambahkan.');
    }

    public function update(Request $request, Quest $quest): RedirectResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'type' => ['required', 'string', 'max:50'],
            'mode' => ['required', 'string', 'max:30'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'points' => ['required', 'integer', 'min:0'],
            'unlock_radius_m' => ['required', 'numeric', 'min:1'],
            'accuracy_threshold_m' => ['required', 'numeric', 'min:1'],
            'qr_code' => ['nullable', 'string', 'max:120'],
            'instruction' => ['nullable', 'string'],
            'quiz_question' => ['nullable', 'string'],
            'quiz_options' => ['nullable', 'string'],
            'quiz_answer' => ['nullable', 'string', 'max:255'],
            'timer_seconds' => ['nullable', 'integer', 'min:10'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $quest->update([
            ...$validated,
            'quiz_options' => $this->decodeQuizOptions($validated['quiz_options'] ?? null),
            'is_active' => (bool) ($validated['is_active'] ?? true),
            'timer_seconds' => (int) ($validated['timer_seconds'] ?? 60),
        ]);

        return back()->with('success', 'Quest berhasil diperbarui.');
    }

    public function destroy(Quest $quest): RedirectResponse
    {
        $quest->delete();

        return back()->with('success', 'Quest berhasil dihapus.');
    }

    private function decodeQuizOptions(?string $raw): ?array
    {
        if ($raw === null || trim($raw) === '') {
            return null;
        }

        return array_values(array_filter(array_map(static fn (string $value): string => trim($value), explode('|', $raw))));
    }

    private function editingQuest(): ?Quest
    {
        $questId = request()->integer('edit');

        if ($questId <= 0) {
            return null;
        }

        return Quest::query()->find($questId);
    }
}
