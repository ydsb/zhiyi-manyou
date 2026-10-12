import { flushPromises, mount, type VueWrapper } from '@vue/test-utils'
import { defineComponent } from 'vue'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { profileApi } from '@/api/profile'
import { skillApi } from '@/api/skill'
import type { SkillProfile, SkillTree } from '@/api/types'
import OnboardingView from './OnboardingView.vue'

vi.mock('vue-router', () => ({ useRouter: () => ({ push: vi.fn(), back: vi.fn() }) }))
vi.mock('@/stores/auth', () => ({ useAuthStore: () => ({ displayName: '同学', completeOnboarding: vi.fn() }) }))
vi.mock('element-plus', () => ({ ElMessage: { warning: vi.fn(), success: vi.fn(), info: vi.fn() } }))
vi.mock('@/api/skill', () => ({ skillApi: { tree: vi.fn(), parse: vi.fn() } }))
vi.mock('@/api/profile', () => ({ profileApi: { mySkills: vi.fn(), saveSkills: vi.fn() } }))

const skill = { id: 1, name: '前端开发', categoryL1: '工学', categoryL2: '计算机' }
const otherSkill = { ...skill, id: 2, name: '统计分析' }
const tree: SkillTree = {
  categoryCount: 1, subCategoryCount: 1, skillCount: 2,
  tree: [{ name: '工学', skillCount: 2, children: [{ name: '计算机', skillCount: 2, skills: [skill, otherSkill] }] }]
}
const mine: SkillProfile = {
  skilled: [{ skill, source: 'SELF' }], researching: [{ skill: otherSkill, source: 'SELF' }],
  needed: [], total: 2, firstLogin: false
}
const Button = defineComponent({
  props: ['disabled', 'loading'],
  template: '<button :disabled="disabled || loading"><slot /></button>'
})
let wrapper: VueWrapper | undefined

function render() {
  wrapper = mount(OnboardingView, {
    shallow: true,
    global: {
      renderStubDefaultSlot: true,
      stubs: { 'el-button': Button },
      directives: { loading: () => {} }
    }
  })
  return wrapper
}

function saveButton() {
  return wrapper!.findAll('button').find((button) => button.text() === '保存并下一步')!
}

beforeEach(() => {
  vi.resetAllMocks()
  vi.mocked(skillApi.tree).mockResolvedValue(tree)
  vi.mocked(profileApi.mySkills).mockResolvedValue(mine)
  vi.mocked(profileApi.saveSkills).mockResolvedValue(mine)
})
afterEach(() => { wrapper?.unmount() })

describe('skill profile initialization and safe editing', () => {
  it('does not allow edits or saving while the existing profile is still loading', async () => {
    let resolve!: (value: SkillProfile) => void
    vi.mocked(profileApi.mySkills).mockReturnValue(new Promise((done) => { resolve = done }))
    render()
    await flushPromises()

    expect(saveButton().attributes('disabled')).toBeDefined()
    await saveButton().trigger('click')
    expect(profileApi.saveSkills).not.toHaveBeenCalled()

    resolve(mine)
    await flushPromises()
    expect(saveButton().attributes('disabled')).toBeUndefined()
    expect(wrapper!.text()).toContain('前端开发')
  })

  it.each(['profile', 'tree'])('blocks saving and offers retry when loading %s fails', async (failed) => {
    if (failed === 'profile') vi.mocked(profileApi.mySkills).mockRejectedValueOnce(new Error('network'))
    else vi.mocked(skillApi.tree).mockRejectedValueOnce(new Error('network'))
    render()
    await flushPromises()

    expect(wrapper!.find('[role="alert"]').text()).toContain('重新加载')
    expect(saveButton().attributes('disabled')).toBeDefined()
    await saveButton().trigger('click')
    expect(profileApi.saveSkills).not.toHaveBeenCalled()

    const retry = wrapper!.findAll('button').find((button) => button.text() === '重新加载')!
    await retry.trigger('click')
    await flushPromises()

    expect(wrapper!.find('[role="alert"]').exists()).toBe(false)
    expect(saveButton().attributes('disabled')).toBeUndefined()
    await saveButton().trigger('click')
    await flushPromises()
    expect(profileApi.saveSkills).toHaveBeenCalledWith([
      { skillId: 1, intent: 'SKILLED' },
      { skillId: 2, intent: 'RESEARCHING' }
    ])
  })
})
