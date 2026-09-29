import { useState, useRef, useEffect, createContext, useContext } from 'react';
import imgCareerlyLogo from "@/imports/CareerlyAppInterfaceDesignCopy-19/c61cbc031dbdc1169262d5946824c2890e8b11f4.png";

// ─── Navigation ───────────────────────────────────────────────────────────────
type NavScreen =
  | 'on-splash' | 'on-register' | 'on-career' | 'on-welcome' | 'on-resume' | 'on-parsing' | 'on-confirm'
  | 'home' | 'analysis' | 'ai' | 'profile'
  | 'a-start' | 'a-resume-step' | 'a-jd-step' | 'a-confirm'
  | 'a-resume' | 'a-targets' | 'a-processing' | 'a-result' | 'a-job' | 'a-gap'
  | 'career-assets' | 'work-exp' | 'work-detail' | 'projects' | 'project-detail'
  | 'skills' | 'awards' | 'capability' | 'cap-change' | 'growth-record'
  | 'resume-history' | 'resume-detail' | 'analysis-history' | 'membership' | 'settings';

type NavParams = Record<string, unknown>;
interface NavCtxType { screen: NavScreen; params: NavParams; go: (s: NavScreen, p?: NavParams) => void; back: () => void; logout: () => void; }
const NavCtx = createContext<NavCtxType>({} as NavCtxType);
const useNav = () => useContext(NavCtx);

type Tab = 'home' | 'analysis' | 'ai' | 'profile';
type Dialog = 'none' | 'quota-done' | 'last-trial' | 'add-job';
type Message = { role: 'ai' | 'user'; text: string };
const MAIN_TABS: NavScreen[] = ['home', 'analysis', 'ai', 'profile'];

// ─── Design Tokens ────────────────────────────────────────────────────────────
const S = {
  bg: 'linear-gradient(128.67deg, rgb(220,233,251) 7.74%, rgb(229,220,250) 45.77%, rgb(251,233,241) 92.27%)',
  glass: { background: 'rgba(255,255,255,0.68)', border: '1px solid rgba(255,255,255,0.55)', backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)', boxShadow: '0 8px 32px rgba(79,126,245,0.08)' } as React.CSSProperties,
  glassLight: { background: 'rgba(255,255,255,0.45)', border: '1px solid rgba(255,255,255,0.4)', backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)', boxShadow: '0 4px 16px rgba(79,126,245,0.05)' } as React.CSSProperties,
  primary: 'linear-gradient(135deg, #4F7EF5 0%, #A77BE6 100%)',
  primaryBlue: '#4F7EF5', primaryPurple: '#A77BE6',
  green: '#34C759', orange: '#FF9500',
  textPrimary: '#111827', textSecondary: '#6B7280',
  divider: 'rgba(229,231,235,0.7)',
};
const gradText: React.CSSProperties = { background: S.primary, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' };

// ─── Data ─────────────────────────────────────────────────────────────────────
const JOBS = [
  { rank: 1, title: 'AI 产品经理', match: 86, prev: 78, delta: 8, gap: 14, matchSource: '3段工作经历、2个AI项目、4项技能' },
  { rank: 2, title: '产品经理', match: 82, prev: 79, delta: 3, gap: 18, matchSource: '3段工作经历、用户研究' },
  { rank: 3, title: '数据产品经理', match: 74, prev: 74, delta: 0, gap: 26, matchSource: '2段工作经历、数据分析经验' },
  { rank: 4, title: '用户增长产品', match: 68, prev: 65, delta: 3, gap: 32, matchSource: '运营经验、用户研究' },
];
const SKILLS_DATA = [
  { name: '产品规划', score: 85, prev: 80, delta: 5 },
  { name: 'AI 应用能力', score: 76, prev: 68, delta: 8 },
  { name: '用户研究', score: 78, prev: 75, delta: 3 },
  { name: '数据分析', score: 60, prev: 58, delta: 2 },
  { name: '项目管理', score: 74, prev: 74, delta: 0 },
];
const TIMELINE = [
  { date: '2026.08', event: '新增 AI Agent 项目', tag: 'AI 能力 +8', effect: 'AI产品经理 78%→86%' },
  { date: '2026.06', event: '完成用户研究认证', tag: '用户研究 +3', effect: '产品经理 76%→79%' },
  { date: '2026.05', event: '更新简历 V2', tag: '产品规划 +5', effect: '多个岗位提升' },
];
const WORK_EXP = [
  { id: 0, title: '产品经理', company: 'AI 科技公司', period: '2024.06 — 至今', desc: '负责 AI 产品规划与落地，主导 3 个 AI 应用产品从 0 到 1 上线，管理跨职能团队协作，推动产品月活增长 40%。', skills: [{ name: '产品规划', delta: 5 }, { name: 'AI 应用能力', delta: 8 }, { name: '项目管理', delta: 3 }], projects: ['AI 招聘助手', 'AI 产品分析工具'] },
  { id: 1, title: '产品设计师', company: '互联网公司', period: '2022.04 — 2024.05', desc: '负责 B 端 SaaS 产品设计，主导用户研究和需求分析，建立设计规范体系，参与多个核心功能从需求到上线全流程。', skills: [{ name: '用户研究', delta: 5 }, { name: '需求分析', delta: 4 }], projects: ['遗墨 VR', '用户研究系统'] },
  { id: 2, title: '建筑设计师', company: '省建筑设计院', period: '2020.07 — 2022.03', desc: '参与多个大型公共建筑项目设计，负责方案设计与施工图绘制，培养了强烈的空间思维与系统规划能力。', skills: [{ name: '项目管理', delta: 2 }, { name: '方案规划', delta: 3 }], projects: [] },
];
const PROJECTS_DATA = [
  { id: 0, name: 'AI 招聘助手', type: 'AI 产品', year: '2026', role: '产品负责人', desc: '基于 LLM 的智能招聘助手，自动筛选简历和安排面试，帮助 HR 将招聘效率提升 60%。设计了完整的产品功能架构与用户交互流程。', outcome: '招聘效率 +60%，月均处理简历 3000+，用户 NPS 72', skills: ['AI 应用能力', '产品规划', '用户研究'], jobImpact: [{ job: 'AI 产品经理', delta: 8 }] },
  { id: 1, name: '职业分析 Agent', type: 'AI 产品', year: '2026', role: '产品负责人', desc: '基于用户职业档案的智能分析系统，帮助用户了解自身能力与目标岗位之间的差距，提供个性化成长建议。', outcome: '完成 MVP 上线，月活 DAU 持续增长', skills: ['AI 应用能力', '数据分析', '产品规划'], jobImpact: [{ job: '数据产品经理', delta: 4 }] },
  { id: 2, name: '遗墨 VR', type: 'VR / 数字文化', year: '2024', role: '产品设计师', desc: '将传统墨迹艺术与 VR 交互结合的文化体验产品，探索数字化文化遗产的新形态，获得省级创新设计奖。', outcome: '省级设计创新奖，媒体报道 12 篇', skills: ['用户研究', '需求分析', '交互设计'], jobImpact: [] },
  { id: 3, name: 'AI 产品分析工具', type: 'AI 工具', year: '2024', role: '产品经理', desc: '面向 B 端客户的 AI 产品效果分析看板，支持实时监控 AI 功能使用率和用户反馈数据，辅助产品决策。', outcome: 'NPS +25，客户续约率 85%', skills: ['数据分析', '产品规划', '用户研究'], jobImpact: [{ job: '数据产品经理', delta: 3 }] },
];
const SKILL_CATS = [
  { cat: '产品能力', skills: ['产品规划', '用户研究', '需求分析', '项目管理', '数据驱动决策'] },
  { cat: 'AI 能力', skills: ['Prompt Engineering', 'AI Agent', 'LLM 应用', 'AI 产品设计'] },
  { cat: '工具', skills: ['Figma', 'Flutter', 'SQL', 'Python 基础'] },
];
const AWARDS = [
  { name: '优秀项目奖', year: '2025', org: 'AI 科技公司', desc: 'AI 招聘助手项目年度最佳产品奖' },
  { name: '设计创新奖', year: '2024', org: '省设计协会', desc: '遗墨 VR 省级数字文化创新设计奖' },
  { name: '优秀毕业设计', year: '2020', org: '华南理工大学', desc: '建筑学院年度优秀毕业设计，TOP 5%' },
];
const INIT_MSGS: Message[] = [
  { role: 'ai', text: '你好！基于最新分析，你在 AI 产品经理方向匹配度达 86%，较上次 ↑8%。有什么想了解的？' },
  { role: 'user', text: '为什么 AI 产品经理排名第一？' },
  { role: 'ai', text: '你的经历有以下优势：\n\n✅ 产品规划能力强（85分）\n✅ 有 AI Agent 项目实战案例\n✅ 用户研究匹配（78分）\n\n当前主要 Gap：AI 技术深度理解、商业化经验。' },
];
const QUICK_QS = ['我的主要 Gap 是什么？', '哪个能力最值得提升？', '下一步应该做什么？'];

// ─── Shared Components ────────────────────────────────────────────────────────
function StatusBar({ light = false }: { light?: boolean }) {
  const [time, setTime] = useState(() => {
    const d = new Date();
    return `${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`;
  });
  useEffect(() => {
    const tick = () => {
      const d = new Date();
      setTime(`${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`);
    };
    const now = new Date();
    const msToNext = (60 - now.getSeconds()) * 1000 - now.getMilliseconds();
    const t = setTimeout(() => { tick(); }, msToNext);
    return () => clearTimeout(t);
  }, [time]);

  const color = light ? 'rgba(255,255,255,0.9)' : '#111827';
  const dimColor = light ? 'rgba(255,255,255,0.55)' : 'rgba(17,24,39,0.45)';

  return (
    <div className="flex items-center justify-between flex-shrink-0" style={{ height: 44, paddingLeft: 20, paddingRight: 16 }}>
      {/* Time */}
      <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 15, color, letterSpacing: 0.3, lineHeight: 1 }}>{time}</span>
      {/* Right icons */}
      <div className="flex items-center gap-[6px]">
        {/* Signal bars */}
        <svg width="17" height="12" viewBox="0 0 17 12" fill="none">
          <rect x="0" y="7" width="3" height="5" rx="0.8" fill={color}/>
          <rect x="4.5" y="4.5" width="3" height="7.5" rx="0.8" fill={color}/>
          <rect x="9" y="2" width="3" height="10" rx="0.8" fill={color}/>
          <rect x="13.5" y="0" width="3" height="12" rx="0.8" fill={dimColor}/>
        </svg>
        {/* WiFi */}
        <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
          <path d="M8 9.5a1.25 1.25 0 1 1 0 2.5 1.25 1.25 0 0 1 0-2.5Z" fill={color}/>
          <path d="M8 6.2C9.55 6.2 10.95 6.82 12 7.84l1.4-1.4A7.18 7.18 0 0 0 8 4.2c-2 0-3.8.81-5.4 2.24L4 7.84A5.18 5.18 0 0 1 8 6.2Z" fill={color}/>
          <path d="M8 3C10.47 3 12.7 3.97 14.36 5.6L15.76 4.2A9.18 9.18 0 0 0 8 1C5.47 1 3.2 1.96 1.5 3.55L2.9 4.95A7.17 7.17 0 0 1 8 3Z" fill={color} opacity="0.4"/>
        </svg>
        {/* Battery */}
        <div className="flex items-center gap-[2px]">
          <div style={{ width: 25, height: 12, borderRadius: 3.5, border: `1.5px solid ${color}`, padding: '1.5px', display: 'flex', alignItems: 'stretch' }}>
            <div style={{ width: '75%', borderRadius: 2, background: color }}/>
          </div>
          <div style={{ width: 2.5, height: 5, borderRadius: '0 1px 1px 0', background: color, opacity: 0.4 }}/>
        </div>
      </div>
    </div>
  );
}
function TrendBadge({ delta }: { delta: number }) {
  if (delta === 0) return <span className="text-[11px] font-medium px-2 py-0.5 rounded-full" style={{ background: 'rgba(107,114,128,0.10)', color: S.textSecondary }}>—</span>;
  if (delta > 0) return <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full" style={{ background: 'rgba(52,199,89,0.12)', color: S.green }}>↑ +{delta}%</span>;
  return <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full" style={{ background: 'rgba(255,59,48,0.10)', color: '#FF3B30' }}>↓ {delta}%</span>;
}
function Card({ children, className = '', style = {}, onClick }: { children: React.ReactNode; className?: string; style?: React.CSSProperties; onClick?: () => void }) {
  return <div className={`rounded-3xl ${className}`} style={{ ...S.glass, ...style }} onClick={onClick}>{children}</div>;
}
function PrimaryBtn({ label, onClick, className = '' }: { label: string; onClick?: () => void; className?: string }) {
  return (
    <button
      onClick={onClick}
      className={`w-full font-bold text-[15px] flex items-center justify-center text-white ${className}`}
      style={{ background: S.primary, boxShadow: '0 8px 24px rgba(79,126,245,0.30)', borderRadius: 99, height: 48, transition: 'transform 120ms cubic-bezier(0.25,0.46,0.45,0.94), opacity 120ms ease' }}
      onPointerDown={e => { e.currentTarget.style.transform = 'scale(0.97)'; e.currentTarget.style.opacity = '0.92'; }}
      onPointerUp={e => { e.currentTarget.style.transform = 'scale(1)'; e.currentTarget.style.opacity = '1'; }}
      onPointerLeave={e => { e.currentTarget.style.transform = 'scale(1)'; e.currentTarget.style.opacity = '1'; }}
    >
      {label}
    </button>
  );
}
function SecondaryBtn({ label, onClick }: { label: string; onClick?: () => void }) {
  return (
    <button
      onClick={onClick}
      className="w-full font-semibold text-[14px] text-center flex items-center justify-center"
      style={{ background: 'rgba(79,126,245,0.08)', color: S.primaryBlue, borderRadius: 99, height: 48, transition: 'transform 120ms cubic-bezier(0.25,0.46,0.45,0.94), opacity 120ms ease' }}
      onPointerDown={e => { e.currentTarget.style.transform = 'scale(0.97)'; e.currentTarget.style.opacity = '0.85'; }}
      onPointerUp={e => { e.currentTarget.style.transform = 'scale(1)'; e.currentTarget.style.opacity = '1'; }}
      onPointerLeave={e => { e.currentTarget.style.transform = 'scale(1)'; e.currentTarget.style.opacity = '1'; }}
    >
      {label}
    </button>
  );
}
function TopBar({ title, onBack, right }: { title?: string; onBack?: () => void; right?: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between px-5 py-3 flex-shrink-0">
      <button
        onClick={onBack}
        className="flex items-center gap-1.5 py-1"
        style={{ transition: 'transform 100ms ease, opacity 100ms ease' }}
        onPointerDown={e => { e.currentTarget.style.transform = 'scale(0.92)'; e.currentTarget.style.opacity = '0.7'; }}
        onPointerUp={e => { e.currentTarget.style.transform = 'scale(1)'; e.currentTarget.style.opacity = '1'; }}
        onPointerLeave={e => { e.currentTarget.style.transform = 'scale(1)'; e.currentTarget.style.opacity = '1'; }}
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
          <path d="M15 18L9 12L15 6" stroke={S.primaryBlue} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
        <span className="text-[14px] font-semibold" style={{ color: S.primaryBlue }}>返回</span>
      </button>
      {title && <span className="text-[15px] font-bold absolute left-1/2 -translate-x-1/2" style={{ color: S.textPrimary }}>{title}</span>}
      <div>{right}</div>
    </div>
  );
}
function Divider() { return <div style={{ height: '1px', background: S.divider }} />; }

// ─── Icons ────────────────────────────────────────────────────────────────────
function IconHome({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M3 10.5L12 3L21 10.5V20C21 20.55 20.55 21 20 21H15V15H9V21H4C3.45 21 3 20.55 3 20V10.5Z" fill={active ? 'url(#ng1)' : 'none'} stroke={active ? 'url(#ng1)' : '#7B7979'} strokeWidth="1.7" strokeLinejoin="round"/>
      <defs><linearGradient id="ng1" x1="3" y1="3" x2="21" y2="21" gradientUnits="userSpaceOnUse"><stop stopColor="#4F7EF5"/><stop offset="1" stopColor="#A77BE6"/></linearGradient></defs>
    </svg>
  );
}
function IconChart({ active }: { active: boolean }) {
  const f = active ? 'url(#ng2)' : '#7B7979';
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <rect x="3" y="14" width="4" height="7" rx="1.5" fill={f}/>
      <rect x="10" y="9" width="4" height="12" rx="1.5" fill={f}/>
      <rect x="17" y="4" width="4" height="17" rx="1.5" fill={f}/>
      <defs><linearGradient id="ng2" x1="3" y1="4" x2="21" y2="21" gradientUnits="userSpaceOnUse"><stop stopColor="#4F7EF5"/><stop offset="1" stopColor="#A77BE6"/></linearGradient></defs>
    </svg>
  );
}
function IconChat({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M12 2C6.48 2 2 6.48 2 12C2 14.07 2.64 15.99 3.74 17.57L2.5 21.5L6.43 20.26C7.97 21.36 9.91 22 12 22C17.52 22 22 17.52 22 12C22 6.48 17.52 2 12 2Z" fill={active ? 'url(#ng3)' : 'none'} stroke={active ? 'url(#ng3)' : '#9CA3AF'} strokeWidth="1.7" strokeLinejoin="round"/>
      <circle cx="8.5" cy="12" r="1.2" fill={active ? 'white' : '#9CA3AF'}/>
      <circle cx="12" cy="12" r="1.2" fill={active ? 'white' : '#9CA3AF'}/>
      <circle cx="15.5" cy="12" r="1.2" fill={active ? 'white' : '#9CA3AF'}/>
      <defs><linearGradient id="ng3" x1="2" y1="2" x2="22" y2="22" gradientUnits="userSpaceOnUse"><stop stopColor="#4F7EF5"/><stop offset="1" stopColor="#A77BE6"/></linearGradient></defs>
    </svg>
  );
}
function IconUser({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="8" r="4" fill={active ? 'url(#ng4)' : 'none'} stroke={active ? 'none' : '#7B7979'} strokeWidth="1.7"/>
      <path d="M4 20C4 16.69 7.58 14 12 14C16.42 14 20 16.69 20 20" stroke={active ? 'url(#ng4)' : '#7B7979'} strokeWidth="1.7" strokeLinecap="round"/>
      <defs><linearGradient id="ng4" x1="4" y1="4" x2="20" y2="20" gradientUnits="userSpaceOnUse"><stop stopColor="#4F7EF5"/><stop offset="1" stopColor="#A77BE6"/></linearGradient></defs>
    </svg>
  );
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
function BottomNav({ tab, setTab }: { tab: Tab; setTab: (t: Tab) => void }) {
  const mainTabs = [{ key: 'home' as Tab, Icon: IconHome }, { key: 'analysis' as Tab, Icon: IconChart }, { key: 'profile' as Tab, Icon: IconUser }];
  const aiActive = tab === 'ai';
  // Sliding pill: tab indices home=0, analysis=1, profile=2
  const activeIdx = mainTabs.findIndex(t => t.key === tab);
  // Each button is 72px wide, gap 2px, container padding-left 6px
  const pillLeft = activeIdx >= 0 ? 6 + activeIdx * 74 : -999;

  return (
    <div className="flex items-center justify-center pb-5 pt-2 pointer-events-none" style={{ gap: 10 }}>
      <div className="relative flex items-center pointer-events-auto" style={{ borderRadius: 30 }}>
        {/* Outer edge highlight */}
        <div style={{
          position: 'absolute', inset: -1, borderRadius: 31, zIndex: 0, pointerEvents: 'none',
          background: 'rgba(255,255,255,0.18)',
          border: '0.5px solid rgba(255,255,255,0.35)',
        }}/>
        {/* Glass surface */}
        <div
          className="relative flex items-center z-10"
          style={{
            padding: '5px 6px', gap: 2, borderRadius: 30,
            background: 'rgba(255,255,255,0.04)',
            backdropFilter: 'blur(10px) saturate(190%) brightness(1.06) contrast(1.01)',
            WebkitBackdropFilter: 'blur(10px) saturate(190%) brightness(1.06) contrast(1.01)',
            boxShadow: [
              'inset 0 1.5px 0 rgba(255,255,255,0.62)',
              'inset 0 -1px 0 rgba(255,255,255,0.12)',
              'inset 1px 0 0 rgba(255,255,255,0.18)',
              'inset -1px 0 0 rgba(255,255,255,0.10)',
              '0 6px 24px rgba(0,0,0,0.08)',
              '0 1px 4px rgba(0,0,0,0.04)',
            ].join(', '),
            border: '0.5px solid rgba(255,255,255,0.30)',
          }}
        >
          {/* Sliding glass selection pill — morphs between tab positions */}
          {activeIdx >= 0 && (
            <div style={{
              position: 'absolute',
              top: 5, left: pillLeft,
              width: 72, height: 50,
              borderRadius: 22,
              background: 'rgba(255,255,255,0.50)',
              backdropFilter: 'blur(6px)',
              WebkitBackdropFilter: 'blur(6px)',
              border: '1.163px solid rgba(255,255,255,0.40)',
              boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.55), 0 1px 6px rgba(0,0,0,0.07)',
              transition: 'left 280ms cubic-bezier(0.34,1.2,0.64,1)',
              pointerEvents: 'none',
              zIndex: 0,
            }}/>
          )}
          {mainTabs.map(({ key, Icon }) => {
            const active = tab === key;
            return (
              <button
                key={key}
                onClick={() => setTab(key)}
                className="flex items-center justify-center relative"
                style={{
                  borderRadius: 22, height: 50, width: 72,
                  zIndex: 1,
                  transition: 'transform 120ms cubic-bezier(0.25,0.46,0.45,0.94)',
                }}
                onPointerDown={e => (e.currentTarget.style.transform = 'scale(0.96)')}
                onPointerUp={e => (e.currentTarget.style.transform = 'scale(1)')}
                onPointerLeave={e => (e.currentTarget.style.transform = 'scale(1)')}
              >
                <Icon active={active}/>
              </button>
            );
          })}
        </div>
      </div>

      {/* AI button — gradient glass orb */}
      <button
        onClick={() => setTab('ai')}
        className="flex flex-col items-center justify-center pointer-events-auto flex-shrink-0"
        style={{
          width: 62, height: 62, borderRadius: 99,
          background: 'linear-gradient(135deg, rgba(79,126,245,0.72) 0%, rgba(167,123,230,0.72) 100%)',
          backdropFilter: 'blur(10px) saturate(200%) brightness(1.1)',
          WebkitBackdropFilter: 'blur(10px) saturate(200%) brightness(1.1)',
          border: '0.5px solid rgba(255,255,255,0.42)',
          boxShadow: 'inset 0 1.5px 0 rgba(255,255,255,0.5), inset 0 -1px 0 rgba(79,126,245,0.2), 0 8px 24px rgba(79,126,245,0.30), 0 2px 6px rgba(0,0,0,0.06)',
          opacity: aiActive ? 1 : 0.88,
          transition: 'transform 120ms cubic-bezier(0.25,0.46,0.45,0.94), opacity 200ms ease',
        }}
        onPointerDown={e => (e.currentTarget.style.transform = 'scale(0.94)')}
        onPointerUp={e => (e.currentTarget.style.transform = 'scale(1)')}
        onPointerLeave={e => (e.currentTarget.style.transform = 'scale(1)')}
      >
        <span style={{ color: 'white', fontSize: 22, lineHeight: '24px', fontFamily: "'Plus Jakarta Sans', sans-serif" }}>✦</span>
        <span style={{ color: 'rgba(255,255,255,0.92)', fontSize: 9, fontWeight: 700, fontFamily: "'Inter', sans-serif", lineHeight: '13.5px', paddingTop: 2 }}>AI</span>
      </button>
    </div>
  );
}

// ─── Radar Chart ─────────────────────────────────────────────────────────────
function RadarChart({ skills }: { skills: typeof SKILLS_DATA }) {
  const cx = 110, cy = 110, r = 76;
  const n = skills.length;
  const angles = skills.map((_, i) => (i * 2 * Math.PI) / n - Math.PI / 2);
  const pt = (val: number, i: number) => ({ x: cx + r * (val / 100) * Math.cos(angles[i]), y: cy + r * (val / 100) * Math.sin(angles[i]) });
  const outer = (i: number, s = 1) => ({ x: cx + r * s * Math.cos(angles[i]), y: cy + r * s * Math.sin(angles[i]) });
  const toD = (pts: { x: number; y: number }[]) => pts.map((p, i) => `${i === 0 ? 'M' : 'L'}${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' ') + 'Z';
  const prev = skills.map((s, i) => pt(s.prev, i));
  const curr = skills.map((s, i) => pt(s.score, i));
  return (
    <svg width="220" height="220" viewBox="0 0 220 220">
      <defs>
        <linearGradient id="rg" x1="0" y1="0" x2="1" y2="1"><stop stopColor="#4F7EF5" stopOpacity="0.5"/><stop offset="1" stopColor="#A77BE6" stopOpacity="0.4"/></linearGradient>
      </defs>
      {[0.25, 0.5, 0.75, 1].map(g => <polygon key={g} points={skills.map((_, i) => `${outer(i, g).x.toFixed(1)},${outer(i, g).y.toFixed(1)}`).join(' ')} fill="none" stroke="rgba(229,231,235,0.6)" strokeWidth="1"/>)}
      {skills.map((_, i) => <line key={i} x1={cx} y1={cy} x2={outer(i).x.toFixed(1)} y2={outer(i).y.toFixed(1)} stroke="rgba(229,231,235,0.5)" strokeWidth="1"/>)}
      <path d={toD(prev)} fill="rgba(167,123,230,0.08)" stroke="rgba(167,123,230,0.3)" strokeWidth="1.5"/>
      <path d={toD(curr)} fill="url(#rg)" stroke="url(#rg)" strokeWidth="2"/>
      {curr.map((p, i) => <circle key={i} cx={p.x} cy={p.y} r="4" fill="white" stroke="#4F7EF5" strokeWidth="2"/>)}
      {skills.map((s, i) => { const op = outer(i, 1.24); return <text key={i} x={op.x.toFixed(1)} y={op.y.toFixed(1)} textAnchor="middle" dominantBaseline="middle" fontSize="9.5" fontWeight="600" fill="#6B7280">{s.name}</text>; })}
    </svg>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONBOARDING
// ═══════════════════════════════════════════════════════════════════════════════

// ── Step 0: Original brand splash ────────────────────────────────────────────
function OnSplash() {
  const { go } = useNav();
  const BG = 'linear-gradient(111deg, rgb(220,233,251) 11.5%, rgb(229,220,250) 46.1%, rgb(251,233,241) 88.5%)';
  return (
    <div className="flex flex-col h-full" style={{ background: BG }}>
      {/* Status bar */}
      <div className="flex items-center justify-between px-6 pt-3 pb-0" style={{ flexShrink: 0 }}>
        <span style={{ fontFamily: "'Roboto:SemiBold', sans-serif", fontWeight: 600, fontSize: 13, color: '#6B7280', fontVariationSettings: '"wdth" 100' }}>9:41</span>
        <div className="flex items-center gap-2">
          <svg width="16" height="12" viewBox="0 0 16 12" fill="none"><rect x="0" y="3.5" width="3" height="8.5" rx="0.5" fill="#6B7280"/><rect x="4.5" y="2" width="3" height="10" rx="0.5" fill="#6B7280"/><rect x="9" y="0.5" width="3" height="11.5" rx="0.5" fill="#111827"/><rect x="13.5" width="2.5" height="12" rx="0.5" fill="#111827"/></svg>
          <svg width="25" height="12" viewBox="0 0 25 12" fill="none"><rect x="0.5" y="0.5" width="21" height="11" rx="3.5" stroke="#6B7280" strokeOpacity="0.35"/><rect x="2" y="2" width="16" height="8" rx="2" fill="#111827"/><path d="M23 4.5V7.5C23.8 7.17 24.5 6.5 24.5 6C24.5 5.5 23.8 4.83 23 4.5Z" fill="#111827"/></svg>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-center text-center px-6 pb-10">
        {/* Orb */}
        <div style={{ width: 141, height: 141, borderRadius: 99, backgroundImage: 'linear-gradient(135deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', boxShadow: '0px 20px 48px 0px rgba(79,126,245,0.35)', marginBottom: 32, flexShrink: 0 }}/>

        {/* Careerly */}
        <p style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 40, lineHeight: '60px', letterSpacing: '-1px', backgroundImage: 'linear-gradient(157deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text', marginBottom: 8, fontVariationSettings: '"wdth" 100' }}>
          Careerly
        </p>

        {/* Subtitle line 1 */}
        <p style={{ fontSize: 22, lineHeight: '33px', color: '#111827', marginBottom: 0 }}>
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700 }}>看见能力</span>
          <span style={{ fontFamily: "'Roboto:SemiBold', sans-serif", fontWeight: 600, fontVariationSettings: '"wdth" 100' }}>{' · '}</span>
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700 }}>跨越</span>
          <span style={{ fontFamily: "'Roboto:SemiBold', sans-serif", fontWeight: 600, fontVariationSettings: '"wdth" 100' }}>{' Gap'}</span>
        </p>
        {/* Subtitle line 2 */}
        <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 22, lineHeight: '37px', color: '#111827', marginBottom: 28 }}>记录成长</p>

        {/* Desc */}
        <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 15, lineHeight: '24px', color: '#6B7280' }}>
          你的职业成长，从看见自己开始。
        </p>
      </div>

      {/* Buttons */}
      <div className="px-6 pb-10 space-y-[14px]">
        <button
          onClick={() => go('on-register')}
          className="w-full active:opacity-90 transition-opacity"
          style={{ height: 48, borderRadius: 99, backgroundImage: 'linear-gradient(172deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', boxShadow: '0px 8px 12px rgba(79,126,245,0.30)' }}
        >
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: 'white', lineHeight: '22.5px' }}>点击登录</span>
        </button>
        <button
          onClick={() => go('on-register')}
          className="w-full active:opacity-80 transition-opacity"
          style={{ height: 48, borderRadius: 99, background: 'white', boxShadow: '0px 4px 2px rgba(186,185,188,0.24)' }}
        >
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: '#6B7280', lineHeight: '19.5px' }}>点击注册</span>
        </button>
      </div>
    </div>
  );
}

// ── Onboarding progress bar ───────────────────────────────────────────────────
function OnboardingProgress({ step, total }: { step: number; total: number }) {
  const { back } = useNav();
  const pct = Math.round((step / total) * 100);
  return (
    <div className="flex items-center gap-[29px] px-6 py-[10px] flex-shrink-0">
      {/* Glass pill back button — matches import FillShadow + GlassEffect */}
      <button
        onClick={back}
        className="flex items-center justify-center active:scale-90 transition-transform flex-shrink-0"
        style={{
          width: 44, height: 44, borderRadius: 296,
          background: 'rgba(255,255,255,0.55)',
          boxShadow: '1.25px 0 0 -0.75px #d0d0d0, -1.25px 0 0 -0.75px #d0d0d0, 0 0 0 0.5px #e8e8e8, 0 8px 15px rgba(0,0,0,0.02), inset 0 40px 10px -40px #e6e6e6, inset 0 -40px 10px -40px #e6e6e6',
          backdropFilter: 'blur(12px)',
        }}
      >
        <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
          <path d="M15 18L9 12L15 6" stroke="#0088FF" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </button>
      {/* Single gradient progress bar */}
      <div className="relative flex-1 overflow-hidden" style={{ height: 7, borderRadius: 9999, background: 'rgba(79,126,245,0.12)' }}>
        <div
          className="absolute top-0 left-[-4px] h-full rounded-full transition-all duration-500"
          style={{ width: `calc(${pct}% + 4px)`, backgroundImage: 'linear-gradient(172deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)' }}
        />
      </div>
    </div>
  );
}

// ── Step 0: Register ──────────────────────────────────────────────────────────
function OnRegister() {
  const { go } = useNav();
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');

  const LABEL: React.CSSProperties = {
    fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 14,
    color: '#727272', letterSpacing: '0.3px', textTransform: 'uppercase', lineHeight: '16.5px',
  };
  const INPUT_BASE: React.CSSProperties = {
    width: '100%', background: 'transparent', fontSize: 16,
    color: S.textPrimary, borderBottom: '1.217px solid rgba(79,126,245,0.25)',
    paddingBottom: 10, paddingTop: 4,
  };

  return (
    <div className="flex flex-col h-full" style={{ backgroundImage: 'linear-gradient(143deg, #EEF2FF 8.5%, #F5F3FF 50%, #FDF4FF 91.5%)' }}>
      <OnboardingProgress step={1} total={4}/>
      <div className="flex-1 overflow-y-auto px-6 pb-6 flex flex-col">
        {/* Title */}
        <div className="mb-0 mt-2">
          <p style={{ fontSize: 0, lineHeight: 0 }}>
            <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 900, fontSize: 26, lineHeight: '32px', color: '#111827' }}>创建你的个人账号</span>
            <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 800, fontSize: 26, lineHeight: '32px', color: '#111827', fontVariationSettings: '"wdth" 100' }}>{' 📋'}</span>
          </p>
        </div>
        <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#6B7280', lineHeight: '20px', marginTop: 8, marginBottom: 32, width: 260 }}>只有你能看到你的个人信息，不会对外展示。</p>

        {/* Avatar */}
        <div className="flex items-center justify-center mb-8">
          <div className="relative" style={{ width: 80, height: 88, flexShrink: 0 }}>
            <div className="flex items-center justify-center" style={{ width: 80, height: 80, borderRadius: 40, backgroundImage: 'linear-gradient(135deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', boxShadow: '0px 12px 16px rgba(79,126,245,0.28)' }}>
              <svg width="36" height="36" viewBox="0 0 36 36" fill="none">
                <circle cx="18" cy="13" r="7" fill="white" fillOpacity="0.9"/>
                <path d="M5 34C5 26.27 11.27 20 19 20C26.73 20 33 26.27 33 34" stroke="white" strokeWidth="2.5" strokeLinecap="round"/>
              </svg>
            </div>
            <div className="absolute flex items-center justify-center" style={{ width: 26, height: 26, borderRadius: 13, background: 'white', boxShadow: '0px 2px 4px rgba(0,0,0,0.12)', bottom: 0, right: 0 }}>
              <svg width="13" height="13" viewBox="0 0 13 13" fill="none">
                <path d="M6 1H2a1.5 1.5 0 0 0-1.5 1.5v8A1.5 1.5 0 0 0 2 12h8a1.5 1.5 0 0 0 1.5-1.5V7" stroke="#4F7EF5" strokeWidth="1.08" strokeLinecap="round" strokeLinejoin="round"/>
                <path d="M10.5 0.5a1.5 1.5 0 0 1 2 2L6 9l-3 0.5L3.5 6.5 10.5 0.5z" stroke="#4F7EF5" strokeWidth="1.08" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </div>
          </div>
        </div>

        {/* Fields */}
        <div className="flex-1" style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
          {/* 姓名 */}
          <div>
            <p style={LABEL}>姓名</p>
            <div style={{ position: 'relative', height: 39 }}>
              <input
                value={name} onChange={e => setName(e.target.value)}
                placeholder="你的名字"
                style={{ ...INPUT_BASE, fontFamily: "'Noto Sans SC:Regular', sans-serif", position: 'absolute', inset: 0, height: '100%' }}
              />
            </div>
          </div>
          {/* 手机号 */}
          <div style={{ marginTop: 28 }}>
            <p style={{ ...LABEL, color: '#6B7280' }}>手机号</p>
            <div style={{ position: 'relative', height: 39 }}>
              <input
                value={phone} onChange={e => setPhone(e.target.value)}
                placeholder="+86 138 0000 0000" type="tel"
                style={{ ...INPUT_BASE, fontFamily: "'Roboto:Regular', sans-serif", fontVariationSettings: '"wdth" 100', position: 'absolute', inset: 0, height: '100%' }}
              />
            </div>
          </div>
          {/* 邮箱 */}
          <div style={{ marginTop: 28 }}>
            <p style={{ ...LABEL, color: '#6B7280' }}>邮箱（选填）</p>
            <div style={{ position: 'relative', height: 39 }}>
              <input
                value={email} onChange={e => setEmail(e.target.value)}
                placeholder="your@email.com" type="email"
                style={{ ...INPUT_BASE, fontFamily: "'Roboto:Regular', sans-serif", fontVariationSettings: '"wdth" 100', position: 'absolute', inset: 0, height: '100%' }}
              />
            </div>
          </div>
        </div>

        {/* Buttons */}
        <div style={{ paddingTop: 32, paddingBottom: 4 }}>
          <button
            onClick={() => go('on-welcome')}
            className="w-full active:opacity-90 transition-opacity"
            style={{ height: 48, borderRadius: 99, backgroundImage: 'linear-gradient(172deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', boxShadow: '0px 8px 12px rgba(79,126,245,0.30)', marginBottom: 12 }}
          >
            <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: 'white', lineHeight: '22.5px' }}>继续</span>
          </button>
          <button onClick={() => go('on-welcome')} className="w-full active:opacity-70 transition-opacity" style={{ height: 24 }}>
            <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#6B7280', lineHeight: '19.5px' }}>跳过，稍后完善</span>
          </button>
        </div>
      </div>
    </div>
  );
}

// ── Step 1: Value intro ───────────────────────────────────────────────────────
function OnWelcome() {
  const { go } = useNav();
  const CARDS = [
    {
      icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="#4F7EF5" strokeWidth="1.8"/><path d="M12 8v4l2.5 2.5" stroke="#4F7EF5" strokeWidth="1.8" strokeLinecap="round"/></svg>,
      title: '看见能力', desc: '了解你已积累的职业能力，让优势变得可见。',
      bg: 'rgba(79,126,245,0.10)', check: '#4F7EF5',
    },
    {
      icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M22 12h-4l-3 9L9 3l-3 9H2" stroke="#A77BE6" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>,
      title: '找到 Gap', desc: '看见你与目标岗位之间的距离，知道差在哪里。',
      bg: 'rgba(167,123,230,0.18)', check: '#A77BE6',
    },
    {
      icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M23 6l-9.5 9.5-5-5L1 18" stroke="#34C759" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>,
      title: '持续成长', desc: '每一次进步都被记录，见证真实的职业成长。',
      bg: 'rgba(52,199,89,0.12)', check: '#34C759',
    },
  ];
  const BG = 'linear-gradient(143deg, #EEF2FF 8.5%, #F5F3FF 50%, #FDF4FF 91.5%)';
  return (
    <div className="flex flex-col h-full" style={{ backgroundImage: BG }}>
      <OnboardingProgress step={2} total={3}/>
      <div className="flex-1 flex flex-col px-6 pt-4 pb-8 overflow-y-auto">
        {/* Brand mark */}
        <div className="flex items-center gap-3 mb-5">
          <div className="flex items-center justify-center" style={{ width: 44, height: 44, borderRadius: 14, backgroundImage: 'linear-gradient(135deg, #4F7EF5 0%, #A77BE6 100%)', boxShadow: '0 10px 14px rgba(79,126,245,0.28)' }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" fill="white" fillOpacity="0.9"/><path d="M4 20c0-4.42 3.58-8 8-8s8 3.58 8 8" stroke="white" strokeWidth="2" strokeLinecap="round"/></svg>
          </div>
          <span style={{ fontFamily: "'Roboto:ExtraBold', sans-serif", fontWeight: 800, fontSize: 20, color: '#4F7EF5', fontVariationSettings: '"wdth" 100' }}>Careerly</span>
        </div>

        <h1 style={{ fontFamily: "'Noto Sans SC:Black', sans-serif", fontWeight: 900, fontSize: 28, color: '#111827', lineHeight: '36px', marginBottom: 10 }}>
          看见你的能力，<br/>找到下一步。
        </h1>
        <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontSize: 13, color: '#6B7280', lineHeight: '22px', marginBottom: 20 }}>
          Careerly 帮你了解自己与目标岗位之间的距离，找到真正需要提升的能力，并记录每一次成长。
        </p>

        <div className="space-y-3 flex-1">
          {CARDS.map((c, i) => (
            <div key={i} className="relative flex items-center gap-3 rounded-2xl px-4 py-4" style={{ background: c.bg }}>
              <div className="flex items-center justify-center flex-shrink-0" style={{ width: 36, height: 36, borderRadius: 99, background: 'rgba(255,255,255,0.60)' }}>
                {c.icon}
              </div>
              <div className="flex-1">
                <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: '#201E22', marginBottom: 2 }}>{c.title}</p>
                <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontSize: 12, color: '#727272', lineHeight: '18px' }}>{c.desc}</p>
              </div>
              <div className="flex items-center justify-center flex-shrink-0" style={{ width: 24, height: 24, borderRadius: 12, background: c.check }}>
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M5 13L9 17L19 7" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </div>
            </div>
          ))}
        </div>

        <div className="pt-6 space-y-3">
          <button
            onClick={() => go('on-resume')}
            className="w-full active:opacity-90 transition-opacity"
            style={{ height: 48, borderRadius: 99, backgroundImage: 'linear-gradient(172deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', boxShadow: '0px 8px 12px rgba(79,126,245,0.30)' }}
          >
            <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: 'white' }}>开始建立我的职业画像</span>
          </button>
          <button className="w-full text-center py-2 active:opacity-70" style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontSize: 13, color: '#6B7280' }} onClick={() => go('home')}>
            稍后再说
          </button>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONBOARDING: CAREER INTRO (OnCareer)
// ═══════════════════════════════════════════════════════════════════════════════

function OnCareer() {
  const { go, back } = useNav();
  const BG = 'linear-gradient(143deg, #EEF2FF 8.5%, #F5F3FF 50%, #FDF4FF 91.5%)';
  const grad = 'linear-gradient(172deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)';
  const iconGrad = 'linear-gradient(135deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)';

  const cards = [
    {
      bg: 'rgba(167,123,230,0.5)',
      check: '#4F7EF5',
      icon: (
        <svg width="20" height="20" viewBox="0 0 19.998 19.998" fill="none">
          <circle cx="9.999" cy="9.999" r="8.3325" stroke="#4F7EF5" strokeWidth="1.5"/>
          <path d="M9.999 6.666V9.999L12.4987 12.4987" stroke="#4F7EF5" strokeLinecap="round" strokeWidth="1.5"/>
        </svg>
      ),
      title: '看见能力',
      desc: '了解你已积累的职业能力，让优势变得可见。',
    },
    {
      bg: 'rgba(79,126,245,0.33)',
      check: '#A77BE6',
      icon: (
        <svg width="20" height="20" viewBox="0 0 19.998 19.998" fill="none">
          <path d="M18.3315 9.999H14.9985L12.4987 17.4982L7.49925 2.49975L4.9995 9.999H1.6665" stroke="#A77BE6" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5"/>
        </svg>
      ),
      title: <span><span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif" }}>找到</span><span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontVariationSettings: '"wdth" 100' }}> Gap</span></span>,
      desc: '看见你与目标岗位之间的距离，知道差在哪里。',
    },
    {
      bg: 'rgba(202,219,143,0.5)',
      check: '#34C759',
      icon: (
        <svg width="20" height="20" viewBox="0 0 19.998 19.998" fill="none">
          <path d="M19.1647 4.9995L11.2489 12.9154L7.08263 8.74913L0.83325 14.9985" stroke="#34C759" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5"/>
        </svg>
      ),
      title: '持续成长',
      desc: '每一次进步都被记录，见证真实的职业成长。',
    },
  ];

  return (
    <div className="flex flex-col h-full" style={{ background: BG }}>
      <OnboardingProgress step={2} total={4} />
      <div className="flex-1 overflow-y-auto px-6 pt-4 pb-4">
        {/* Brand */}
        <div className="flex items-center gap-3 mb-8">
          <div style={{ width: 44, height: 44, borderRadius: 14, backgroundImage: iconGrad, boxShadow: '0px 10px 14px rgba(79,126,245,0.30)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <svg width="22" height="22" viewBox="0 0 21.994 21.994" fill="none">
              <path d="M10.997 10.997C13.0215 10.997 14.6627 9.35583 14.6627 7.33133C14.6627 5.30684 13.0215 3.66567 10.997 3.66567C8.97251 3.66567 7.33133 5.30684 7.33133 7.33133C7.33133 9.35583 8.97251 10.997 10.997 10.997Z" fill="white" fillOpacity="0.9"/>
              <path d="M3.66567 18.3283C3.66567 14.2778 6.94644 10.997 10.997 10.997C15.0476 10.997 18.3283 14.2778 18.3283 18.3283" stroke="white" strokeLinecap="round" strokeWidth="1.83"/>
            </svg>
          </div>
          <p style={{ fontFamily: "'Roboto:ExtraBold', sans-serif", fontWeight: 800, fontSize: 20, backgroundImage: 'linear-gradient(158deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text', fontVariationSettings: '"wdth" 100' }}>Careerly</p>
        </div>
        {/* Heading */}
        <div style={{ marginBottom: 16 }}>
          <p style={{ fontFamily: "'Noto Sans SC:Black', sans-serif", fontWeight: 900, fontSize: 28, color: '#111827', lineHeight: '36px' }}>看见你的能力，</p>
          <p style={{ fontFamily: "'Noto Sans SC:Black', sans-serif", fontWeight: 900, fontSize: 28, color: '#111827', lineHeight: '36px' }}>找到下一步。</p>
        </div>
        {/* Description */}
        <p style={{ fontSize: 14, lineHeight: '22px', color: '#6B7280', marginBottom: 24 }}>
          <span style={{ fontFamily: "'Roboto:Regular', sans-serif", fontWeight: 400, fontVariationSettings: '"wdth" 100' }}>Careerly </span>
          <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400 }}>帮你了解自己与目标岗位之间的距离，找到真正需要提升的能力，并记录每一次成长。</span>
        </p>
        {/* Cards */}
        <div className="flex flex-col gap-3">
          {cards.map((card, i) => (
            <div key={i} style={{ height: 73, borderRadius: 16, background: card.bg, position: 'relative', flexShrink: 0 }}>
              {/* Icon circle */}
              <div style={{ position: 'absolute', left: 16, top: 18, width: 36, height: 36, borderRadius: 99, background: 'rgba(255,255,255,0.60)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                {card.icon}
              </div>
              {/* Text */}
              <div style={{ position: 'absolute', left: 68, top: 16, right: 44 }}>
                <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: '#111827', lineHeight: '21px' }}>{card.title}</p>
                <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: '#6B7280', lineHeight: '18px', marginTop: 2 }}>{card.desc}</p>
              </div>
              {/* Check badge */}
              <div style={{ position: 'absolute', right: 16, top: 8, width: 24, height: 24, borderRadius: 12, background: card.check, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <svg width="13" height="13" viewBox="0 0 12.9835 12.9835" fill="none">
                  <path d="M2.7049 7.03273L4.86881 9.19665L10.2786 3.78685" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.35"/>
                </svg>
              </div>
            </div>
          ))}
        </div>
      </div>
      {/* Buttons */}
      <div className="px-6 pb-10 pt-6 flex flex-col gap-3">
        <button onClick={() => go('on-welcome')} className="w-full" style={{ height: 48, borderRadius: 99, backgroundImage: grad, boxShadow: '0px 8px 12px rgba(79,126,245,0.30)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: 'white' }}>开始建立我的职业画像</span>
        </button>
        <button onClick={back} className="w-full" style={{ height: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#6B7280' }}>稍后再说</span>
        </button>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONBOARDING: RESUME UPLOAD
// ═══════════════════════════════════════════════════════════════════════════════

function OnResume() {
  const { go } = useNav();
  const BG = 'linear-gradient(143deg, #EEF2FF 8.5%, #F5F3FF 50%, #FDF4FF 91.5%)';
  const iconBg = 'linear-gradient(135deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)';
  const grad = 'linear-gradient(172deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)';
  const extractItems = ['工作经历与职位信息', '项目经历与成果', '教育背景', '技能与证书', '获奖与荣誉'];
  return (
    <div className="flex flex-col h-full" style={{ background: BG }}>
      <OnboardingProgress step={3} total={3} />
      <div className="flex-1 overflow-y-auto px-6 pt-4 pb-8 space-y-6">
        <div>
          <p style={{ fontFamily: "'Noto Sans SC:Black', sans-serif", fontWeight: 900, fontSize: 24, color: '#111827', lineHeight: '36px', marginBottom: 6 }}>上传你的简历</p>
          <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#6B7280', lineHeight: '20px' }}>支持 PDF、Word 格式，AI 将自动解析你的职业经历</p>
        </div>
        {/* Upload card */}
        <div style={{ border: '1.5px dashed rgba(79,126,245,0.35)', borderRadius: 20, padding: '32px 24px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16, background: 'rgba(255,255,255,0.55)' }}>
          <div style={{ width: 60, height: 60, borderRadius: 18, backgroundImage: iconBg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
              <path d="M14 6v12M9 11l5-5 5 5" stroke="white" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M5 22h18" stroke="white" strokeWidth="2.2" strokeLinecap="round"/>
            </svg>
          </div>
          <div className="text-center">
            <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: '#111827' }}>点击或拖拽上传简历</p>
            <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: '#9CA3AF', marginTop: 4 }}>PDF / Word · 最大 10MB</p>
          </div>
        </div>
        {/* Extract items */}
        <div>
          <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 13, color: '#6B7280', marginBottom: 12 }}>AI 将自动提取</p>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px 12px' }}>
            {extractItems.map((item, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                  <circle cx="7" cy="7" r="7" fill="rgba(79,126,245,0.12)"/>
                  <path d="M4 7l2 2 4-4" stroke="#4F7EF5" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
                <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: '#374151' }}>{item}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
      <div className="px-6 pb-10 space-y-3">
        <button onClick={() => go('on-parsing')} className="w-full" style={{ height: 48, borderRadius: 99, backgroundImage: grad, boxShadow: '0px 8px 12px rgba(79,126,245,0.28)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: 'white' }}>选择文件</span>
        </button>
        <button onClick={() => go('on-parsing')} className="w-full" style={{ height: 48, borderRadius: 99, background: 'white', border: '1.5px solid rgba(79,126,245,0.35)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 15, color: '#4F7EF5' }}>粘贴简历文本</span>
        </button>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONBOARDING: PARSING
// ═══════════════════════════════════════════════════════════════════════════════

function OnParsing() {
  const { go, back } = useNav();
  const STEPS = [
    { label: '岗位需求解析', sub: 'AI 提取核心职责与技能要求', dur: 1200, pEnd: 20 },
    { label: '简历信息解析', sub: 'AI 提取经历、项目与能力证据', dur: 1800, pEnd: 50 },
    { label: '能力匹配分析', sub: '将简历能力与岗位要求深度匹配', dur: 2000, pEnd: 75 },
    { label: '识别能力 Gap', sub: '分析与岗位要求之间的成长空间', dur: 1200, pEnd: 90 },
    { label: '生成分析报告', sub: '整理匹配度、排名与改进建议', dur: 800, pEnd: 100 },
  ];
  const PCT_START = [0, 20, 50, 75, 90];
  const [stepIdx, setStepIdx] = useState(0);
  const [pct, setPct] = useState(1);
  const [done, setDone] = useState(false);

  useEffect(() => {
    let raf: number;
    let startTime: number | null = null;
    const step = STEPS[stepIdx];
    const pStart = PCT_START[stepIdx];

    const tick = (ts: number) => {
      if (!startTime) startTime = ts;
      const elapsed = ts - startTime;
      const frac = Math.min(elapsed / step.dur, 1);
      const eased = 1 - Math.pow(1 - frac, 2.2);
      setPct(Math.round(pStart + (step.pEnd - pStart) * eased));
      if (frac < 1) { raf = requestAnimationFrame(tick); return; }
      if (stepIdx < STEPS.length - 1) {
        setTimeout(() => setStepIdx(i => i + 1), 300);
      } else {
        setDone(true);
      }
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [stepIdx]);

  useEffect(() => {
    if (done) { const t = setTimeout(() => go('on-confirm'), 700); return () => clearTimeout(t); }
  }, [done]);

  const grad = 'linear-gradient(172deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)';
  return (
    <div className="flex flex-col h-full" style={{ background: 'linear-gradient(143deg, #EEF2FF 8.5%, #F5F3FF 50%, #FDF4FF 91.5%)' }}>
      {/* Top bar */}
      <div className="flex items-center px-6 pt-3 pb-2 relative">
        <button onClick={back} style={{ width: 44, height: 44, borderRadius: 999, background: 'rgba(255,255,255,0.55)', backdropFilter: 'blur(12px)', boxShadow: '0 0 0 0.5px #e8e8e8, 0 8px 15px rgba(0,0,0,0.02)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <svg width="17" height="17" viewBox="0 0 17 17" fill="none"><path d="M10.5 13.5L5.5 8.5L10.5 3.5" stroke="#4F7EF5" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </button>
        <p className="absolute left-1/2 -translate-x-1/2" style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 16, color: '#111827' }}>正在解析</p>
      </div>
      <div className="flex-1 flex flex-col items-center px-6 pt-4 pb-4 overflow-hidden">
        {/* Status pill */}
        <div style={{ padding: '5px 16px', borderRadius: 99, background: 'rgba(79,126,245,0.10)', marginBottom: 20 }}>
          <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#4F7EF5' }}>{done ? '解析完成' : STEPS[stepIdx].label}</span>
        </div>
        {/* Orb */}
        <div className="relative flex items-center justify-center" style={{ width: 160, height: 160, marginBottom: 20 }}>
          <div className={done ? 'ai-orb-complete' : 'ai-halo'} style={{ position: 'absolute', width: 160, height: 160, borderRadius: 99, opacity: 0.18, backgroundImage: grad }}/>
          <div className={done ? '' : 'ai-halo-2'} style={{ position: 'absolute', width: 128, height: 128, borderRadius: 99, opacity: 0.25, backgroundImage: grad }}/>
          <div className={done ? 'ai-orb-complete' : 'ai-orb'} style={{ width: 96, height: 96, borderRadius: 99, backgroundImage: grad, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 16px 40px rgba(79,126,245,0.35)' }}>
            {done
              ? <svg width="36" height="36" viewBox="0 0 36 36" fill="none"><path d="M8 18l7 7 13-13" stroke="white" strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
              : <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 22, color: 'white' }}>{pct}%</span>
            }
          </div>
        </div>
        {/* Pct label */}
        {!done && <p style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 36, color: '#111827', lineHeight: 1, marginBottom: 4 }}>{pct}%</p>}
        {done && <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 18, color: '#34C759', marginBottom: 4 }}>解析完成！</p>}
        <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#6B7280', marginBottom: 20 }}>正在认识</p>
        {/* Step cards */}
        <div style={{ width: '100%', borderRadius: 20, background: 'rgba(255,255,255,0.65)', backdropFilter: 'blur(16px)', padding: '12px 16px', display: 'flex', flexDirection: 'column', gap: 0, boxShadow: '0 2px 20px rgba(79,126,245,0.08)' }}>
          {STEPS.map((s, i) => {
            const isComplete = i < stepIdx || done;
            const isActive = i === stepIdx && !done;
            const stepPct = isComplete ? 100 : isActive ? Math.round(((pct - PCT_START[i]) / (s.pEnd - PCT_START[i])) * 100) : 0;
            return (
              <div key={i} style={{ paddingTop: 10, paddingBottom: 10, borderBottom: i < STEPS.length - 1 ? '1px solid rgba(0,0,0,0.05)' : 'none' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  {isComplete
                    ? <div style={{ width: 22, height: 22, borderRadius: 11, background: '#34C759', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                        <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-5" stroke="white" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
                      </div>
                    : isActive
                    ? <div style={{ width: 22, height: 22, borderRadius: 11, backgroundImage: grad, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                        <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 11, color: 'white' }}>{i + 1}</span>
                      </div>
                    : <div style={{ width: 22, height: 22, borderRadius: 11, background: 'rgba(0,0,0,0.08)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                        <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 11, color: '#9CA3AF' }}>{i + 1}</span>
                      </div>
                  }
                  <div style={{ flex: 1 }}>
                    <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 13, color: isComplete ? '#34C759' : isActive ? '#111827' : '#9CA3AF' }}>{s.label}</p>
                    {isActive && <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#6B7280', marginTop: 2 }}>{s.sub}</p>}
                  </div>
                </div>
                {isActive && (
                  <div style={{ marginTop: 8, height: 4, borderRadius: 9999, background: 'rgba(79,126,245,0.12)', overflow: 'hidden' }}>
                    <div style={{ height: '100%', borderRadius: 9999, backgroundImage: grad, width: `${stepPct}%`, transition: 'width 0.1s linear' }}/>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
      <div className="px-6 pb-10">
        <button onClick={back} className="w-full" style={{ height: 44, borderRadius: 99, background: 'rgba(255,255,255,0.60)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 0 0 1px rgba(79,126,245,0.20)' }}>
          <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 14, color: '#6B7280' }}>退出分析</span>
        </button>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONBOARDING: CONFIRM
// ═══════════════════════════════════════════════════════════════════════════════

function OnConfirm() {
  const { go } = useNav();
  const grad = 'linear-gradient(135deg, rgb(91,124,246) 0%, rgb(167,123,230) 100%)';
  const rows = [
    { n: 1, title: '工作经历', desc: '已识别你的职业经历', count: 4, unit: '段' },
    { n: 2, title: '项目经历', desc: '已整理你的项目经验', count: 6, unit: '个' },
    { n: 3, title: '能力与技能', desc: '已提取你的职业能力与技能', count: 12, unit: '项' },
    { n: 4, title: '获奖经历', desc: '已提取你的职业荣誉', count: 5, unit: '项' },
  ];
  return (
    <div className="flex flex-col h-full" style={{ background: 'linear-gradient(143deg, #EEF2FF 8.5%, #F5F3FF 50%, #FDF4FF 91.5%)' }}>
      {/* Thin top gradient bar */}
      <div style={{ height: 7, backgroundImage: grad }}/>
      <div className="flex-1 flex flex-col items-center px-6 pt-10 pb-4 overflow-y-auto">
        {/* Hero ring + circle */}
        <div style={{ position: 'relative', width: 126, height: 126, marginBottom: 24 }}>
          <div style={{ position: 'absolute', inset: 0, borderRadius: 63, border: '2px solid rgba(79,126,245,0.20)' }}/>
          <div style={{ position: 'absolute', inset: 13, borderRadius: 50, backgroundImage: grad, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 16px 40px rgba(79,126,245,0.35)' }}>
            <svg width="40" height="40" viewBox="0 0 40 40" fill="none"><path d="M8 20l8 8 16-16" stroke="white" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </div>
        </div>
        <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 22, color: '#111827', textAlign: 'center', marginBottom: 8 }}>你的职业档案已建立！</p>
        <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 14, color: '#6B7280', textAlign: 'center', marginBottom: 28 }}>Careerly 已完成初步解析，你可以随时完善</p>
        {/* Frosted card */}
        <div style={{ width: '100%', borderRadius: 20, background: 'rgba(255,255,255,0.65)', backdropFilter: 'blur(16px)', padding: '4px 20px', boxShadow: '0 2px 20px rgba(79,126,245,0.08)', marginBottom: 20 }}>
          {rows.map((r, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '14px 0', borderBottom: i < rows.length - 1 ? '1px solid rgba(0,0,0,0.05)' : 'none' }}>
              <div style={{ width: 28, height: 28, borderRadius: 14, backgroundImage: grad, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 12, color: 'white' }}>{r.n}</span>
              </div>
              <div style={{ flex: 1 }}>
                <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: '#111827' }}>{r.title}</p>
                <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: '#9CA3AF', marginTop: 2 }}>{r.desc}</p>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <div style={{ width: 8, height: 8, borderRadius: 4, background: '#34C759' }}/>
                <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 16, color: '#111827' }}>{r.count}</span>
                <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: '#6B7280' }}>{r.unit}</span>
              </div>
            </div>
          ))}
        </div>
        {/* Banner */}
        <div style={{ width: '100%', borderRadius: 14, background: 'rgba(79,126,245,0.08)', padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 10, marginBottom: 28 }}>
          <span style={{ fontSize: 18 }}>🚀</span>
          <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: '#4F7EF5', lineHeight: '18px' }}>你的职业基线已建立 · 这是你成长的起点</p>
        </div>
      </div>
      <div className="px-6 pb-10">
        <button onClick={() => go('home')} className="w-full" style={{ height: 48, borderRadius: 99, backgroundImage: grad, boxShadow: '0px 8px 12px rgba(79,126,245,0.28)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: 'white' }}>进入 Careerly</span>
        </button>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME
// ═══════════════════════════════════════════════════════════════════════════════

function HomePage({ onAnalysisClick, onAIClick, onGrowthClick }: { onAnalysisClick: () => void; onAIClick: () => void; onGrowthClick: () => void }) {
  // SVG paths inlined from CareerlyAppInterfaceDesignCopy-16
  const arcTrack = "M173 86.5C173 134.273 134.273 173 86.5 173C38.7274 173 0 134.273 0 86.5C0 38.7274 38.7274 0 86.5 0C134.273 0 173 38.7274 173 86.5ZM17.3 86.5C17.3 124.718 48.2819 155.7 86.5 155.7C124.718 155.7 155.7 124.718 155.7 86.5C155.7 48.2819 124.718 17.3 86.5 17.3C48.2819 17.3 17.3 48.2819 17.3 86.5Z";
  const arcFill = "M86.5 0C102.453 -6.97307e-07 118.094 4.41145 131.696 12.7466C145.298 21.0818 156.33 33.016 163.572 47.2298C170.814 61.4436 173.985 77.3834 172.733 93.2867C171.482 109.19 165.857 124.438 156.48 137.343C147.103 150.249 134.34 160.311 119.602 166.416C104.864 172.52 88.7245 174.431 72.9684 171.935C57.2123 169.44 42.4531 162.635 30.3227 152.275C18.1923 141.915 9.16321 128.402 4.23361 113.23L20.6869 107.884C24.6306 120.021 31.8539 130.832 41.5582 139.12C51.2625 147.408 63.0698 152.852 75.6747 154.848C88.2796 156.844 101.191 155.316 112.982 150.432C124.772 145.549 134.983 137.499 142.484 127.175C149.985 116.85 154.485 104.652 155.487 91.9294C156.488 79.2067 153.952 66.4549 148.158 55.0839C142.364 43.7128 133.538 34.1654 122.657 27.4973C111.775 20.8292 99.262 17.3 86.5 17.3L86.5 0Z";
  const arrowUR = "M11.3328 11.3328V4.6672H4.6672M11.3328 4.6672L4.6672 11.3328";
  const clockPath = "M6 2.99976V6L8.00016 7.00008M11.0004 6C11.0004 8.76164 8.76164 11.0004 6 11.0004C3.23836 11.0004 0.9996 8.76164 0.9996 6C0.9996 3.23836 3.23836 0.9996 6 0.9996C8.76164 0.9996 11.0004 3.23836 11.0004 6Z";

  const stilCards = [
    {
      iconBg: 'linear-gradient(90deg, #a39efa 0%, #b8c0ff 100%)',
      icon: <path d="M17.5 12.4997L14.9283 9.92808C14.6158 9.61563 14.1919 9.4401 13.75 9.4401C13.3081 9.4401 12.8842 9.61563 12.5717 9.92808L5 17.4997M4.16667 2.5H15.8333C16.7538 2.5 17.5 3.24619 17.5 4.16667V15.8333C17.5 16.7538 16.7538 17.5 15.8333 17.5H4.16667C3.24619 17.5 2.5 16.7538 2.5 15.8333V4.16667C2.5 3.24619 3.24619 2.5 4.16667 2.5ZM9.16667 7.5C9.16667 8.42047 8.42047 9.16667 7.5 9.16667C6.57953 9.16667 5.83333 8.42047 5.83333 7.5C5.83333 6.57953 6.57953 5.83333 7.5 5.83333C8.42047 5.83333 9.16667 6.57953 9.16667 7.5Z" stroke="white" strokeLinecap="round" strokeWidth="2" fill="none" />,
      title: '问问AI',
      desc: <><p style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 11, color: '#6e717c', lineHeight: '15px' }}>补充 AI Agent 项目案例</p><p style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 11, color: '#e07840', lineHeight: '15px' }}>影响 3 个目标岗位</p></>,
      onClick: onAIClick,
    },
    {
      iconBg: 'linear-gradient(90deg, #f7a8d8 0%, #ffccd5 100%)',
      icon: <path d="M2.5 7.5H17.5M2.5 12.5H17.5M7.5 2.5V17.5M12.5 2.5V17.5M4.16667 2.5H15.8333C16.7538 2.5 17.5 3.24619 17.5 4.16667V15.8333C17.5 16.7538 16.7538 17.5 15.8333 17.5H4.16667C3.24619 17.5 2.5 16.7538 2.5 15.8333V4.16667C2.5 3.24619 3.24619 2.5 4.16667 2.5Z" stroke="white" strokeLinecap="round" strokeWidth="2" fill="none" />,
      title: '当前状态',
      desc: <><p style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 11, color: '#6e717c', lineHeight: '15px' }}>排名 #1</p><p style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 11, color: '#6e717c', lineHeight: '15px' }}>点击查看详细分析</p></>,
      onClick: onAnalysisClick,
    },
    {
      iconBg: 'linear-gradient(90deg, #8cb8fa 0%, #bee3f8 100%)',
      icon: <path d="M13.3336 10.8336L17.6864 13.7352C17.7492 13.777 17.8221 13.8009 17.8974 13.8045C17.9727 13.8081 18.0475 13.7912 18.114 13.7557C18.1804 13.7201 18.236 13.6672 18.2747 13.6025C18.3135 13.5379 18.334 13.4639 18.334 13.3886V6.55855C18.334 6.48524 18.3147 6.41322 18.278 6.34976C18.2413 6.2863 18.1884 6.23366 18.1249 6.19714C18.0613 6.16062 17.9892 6.14152 17.9159 6.14177C17.8426 6.14202 17.7706 6.1616 17.7073 6.19855L13.3336 8.75022M3.3328 5H11.6668C12.5873 5 13.3336 5.74619 13.3336 6.66667V13.3333C13.3336 14.2538 12.5873 15 11.6668 15H3.3328C2.41225 15 1.666 14.2538 1.666 13.3333V6.66667C1.666 5.74619 2.41225 5 3.3328 5Z" stroke="white" strokeLinecap="round" strokeWidth="2" fill="none" />,
      title: '最近成长',
      desc: <><p style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 11, color: '#6e717c', lineHeight: '15px' }}>新增 AI Agent 项目</p><p style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 11, color: '#34c759', lineHeight: '15px' }}>AI 能力 68→76 ↑8</p></>,
      onClick: onGrowthClick,
    },
    {
      iconBg: 'linear-gradient(90deg, #c49ef7 0%, #e9d8fd 100%)',
      icon: <path d="M17.8458 16.1779C17.5332 16.4904 17.1093 16.666 16.6672 16.666H3.3328C2.89074 16.666 2.46678 16.4904 2.15419 16.1779C1.84161 15.8653 1.666 15.4414 1.666 14.9994V4.16659C1.666 3.72458 1.84161 3.30068 2.15419 2.98813C2.46678 2.67559 2.89074 2.5 3.3328 2.5H6.60806C6.88401 2.50005 7.15562 2.56859 7.39854 2.69949C7.64146 2.83038 7.84807 3.01953 7.99984 3.24996L8.67489 4.24992C8.82821 4.48272 9.03747 4.67335 9.28353 4.80437C9.52958 4.9354 9.80458 5.00262 10.0833 4.99988H16.6672C17.1093 4.99988 17.5332 5.17547 17.8458 5.48801C18.1584 5.80056 18.334 6.22446 18.334 6.66647V14.9994C18.334 15.4414 18.1584 15.8653 17.8458 16.1779Z" stroke="white" strokeLinecap="round" strokeWidth="2" fill="none" />,
      title: '今日一句',
      desc: <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#7c3aed', lineHeight: '15px' }}>每一段经历，都在悄悄改变你与目标之间的距离。</p>,
      onClick: undefined,
    },
  ];

  const rankEmoji = (r: number) => r === 1 ? '🥇' : r === 2 ? '🥈' : r === 3 ? '🥉' : `${r}`;

  return (
    <div className="px-5 pt-3 pb-6 space-y-4">

      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: '#6b7280', lineHeight: '18px' }}>主页</p>
          <h1 style={{ fontSize: 22, lineHeight: '27.5px', color: S.textPrimary }}>
            <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontVariationSettings: '"wdth" 100' }}>Alex </span>
            <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700 }}>的职业主页</span>
          </h1>
        </div>
        <div className="relative flex-shrink-0">
          <div style={{ width: 44, height: 44, borderRadius: 16, backgroundImage: S.primary, boxShadow: '0 4px 7px rgba(79,126,245,0.35)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 17, color: 'white', fontVariationSettings: '"wdth" 100' }}>A</span>
          </div>
          <div style={{ position: 'absolute', top: -2, right: -2, width: 12, height: 12, borderRadius: 99, background: '#34c759', border: '1.217px solid white' }}/>
        </div>
      </div>

      {/* Hero Card */}
      <div style={{ height: 190, borderRadius: 36, backgroundImage: 'linear-gradient(151.5deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', boxShadow: '0px 20px 48px 0px rgba(79,126,245,0.28)', position: 'relative', overflow: 'hidden' }}>
        {/* Decorative circles */}
        <div style={{ position: 'absolute', left: 230, top: 141, width: 144, height: 144, borderRadius: 99, background: 'rgba(255,255,255,0.07)', pointerEvents: 'none' }}/>
        <div style={{ position: 'absolute', left: -24, top: -38, width: 206, height: 206, borderRadius: 99, background: 'rgba(255,255,255,0.10)', pointerEvents: 'none' }}/>

        {/* Arc SVG (clipped by overflow:hidden) */}
        <div style={{ position: 'absolute', left: 190, top: -17, width: 173, height: 173, pointerEvents: 'none' }}>
          <svg width="173" height="173" viewBox="0 0 173 173" fill="none">
            <path d={arcTrack} fill="#F1F3F9" fillOpacity="0.95"/>
            <defs>
              <linearGradient id="hpArcGrad" x1="0" y1="0" x2="173" y2="0" gradientUnits="userSpaceOnUse">
                <stop stopColor="#A39EFA"/>
                <stop offset="0.519" stopColor="#A39EFA"/>
                <stop offset="1" stopColor="#F7A8D8" stopOpacity="0.8"/>
              </linearGradient>
            </defs>
            <path d={arcFill} fill="url(#hpArcGrad)"/>
          </svg>
        </div>

        {/* Right numbers */}
        <div style={{ position: 'absolute', left: 238, top: 34, width: 97 }}>
          <div style={{ position: 'relative', height: 57 }}>
            <span style={{ position: 'absolute', top: -0.16, left: -0.18, fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 56, lineHeight: '56px', color: 'white', fontVariationSettings: '"wdth" 100', whiteSpace: 'nowrap' }}>86</span>
            <span style={{ position: 'absolute', top: 24, left: 74.9, fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 22, lineHeight: '33px', color: 'rgba(255,255,255,0.8)', fontVariationSettings: '"wdth" 100' }}>%</span>
          </div>
          <p style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: 'rgba(255,255,255,0.55)', lineHeight: '18px' }}>匹配度</p>
          <p style={{ fontSize: 12, lineHeight: '19.5px', color: 'white', whiteSpace: 'nowrap' }}>
            <span style={{ fontFamily: "'Roboto:SemiBold', sans-serif", fontVariationSettings: '"wdth" 100' }}>▲ </span>
            <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700 }}>较上次</span>
            <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700 }}>+8%</span>
          </p>
        </div>

        {/* Left content */}
        <div style={{ position: 'absolute', left: 23, top: 31, width: 160, display: 'flex', flexDirection: 'column', gap: 19 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            <p style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 11, color: 'rgba(255,255,255,0.6)', letterSpacing: '1.1px', textTransform: 'uppercase', lineHeight: '16.5px' }}>最匹配岗位</p>
            <p style={{ fontSize: 21, letterSpacing: '2px', lineHeight: '26.25px', color: 'white' }}>
              <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontVariationSettings: '"wdth" 100' }}>AI </span>
              <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700 }}>产品经理</span>
            </p>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <svg width="14" height="14" viewBox="0 0 12 12" fill="none">
                <path d={clockPath} stroke="white" strokeLinecap="round" strokeOpacity="0.6" strokeWidth="2"/>
              </svg>
              <span style={{ fontFamily: "'Roboto:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: 'rgba(255,255,255,0.6)', fontVariationSettings: '"wdth" 100' }}> 2026/9/12</span>
            </div>
          </div>
          <button onClick={onAnalysisClick} style={{ height: 30, borderRadius: 20, background: '#373b4d', paddingLeft: 16, paddingRight: 16, display: 'flex', alignItems: 'center', justifyContent: 'center', alignSelf: 'flex-start' }}>
            <span style={{ fontFamily: "'Roboto:SemiBold', sans-serif", fontWeight: 600, fontSize: 14, color: 'white', fontVariationSettings: '"wdth" 100', whiteSpace: 'nowrap' }}>查看分析</span>
          </button>
        </div>
      </div>

      {/* 2×2 Stil Cards */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 5 }}>
        {[stilCards.slice(0, 2), stilCards.slice(2, 4)].map((row, ri) => (
          <div key={ri} style={{ display: 'flex', gap: 5, height: 180 }}>
            {row.map((card, ci) => (
              <button
                key={ci}
                onClick={card.onClick}
                style={{ flex: 1, minWidth: 0, background: 'rgba(255,255,255,0.68)', borderRadius: 28, padding: 18, display: 'flex', flexDirection: 'column', justifyContent: 'space-between', alignItems: 'flex-start', position: 'relative', textAlign: 'left', cursor: card.onClick ? 'pointer' : 'default' }}
              >
                <div style={{ position: 'absolute', inset: 0, borderRadius: 28, border: '1.5px solid rgba(255,255,255,0.25)', boxShadow: '0px 8px 20px 0px rgba(155,177,201,0.25)', pointerEvents: 'none' }}/>
                {/* Icon badge */}
                <div style={{ width: 48, height: 48, borderRadius: 14, backgroundImage: card.iconBg, display: 'flex', alignItems: 'center', justifyContent: 'center', alignSelf: 'center' }}>
                  <svg width="20" height="20" viewBox="0 0 20 20" fill="none">{card.icon}</svg>
                </div>
                {/* Content */}
                <div style={{ width: '100%' }}>
                  <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: '#181a20', letterSpacing: '0.75px', lineHeight: 'normal', marginBottom: 4 }}>{card.title}</p>
                  <div>{card.desc}</div>
                </div>
                {/* Arrow */}
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d={arrowUR} stroke="#181A20" strokeLinecap="round" strokeWidth="2"/>
                </svg>
              </button>
            ))}
          </div>
        ))}
      </div>

      {/* Filter Tabs */}
      <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
        <button onClick={onAnalysisClick} style={{ height: 38, borderRadius: 100, background: '#373b4d', padding: '0 20px', display: 'flex', alignItems: 'center', flexShrink: 0 }}>
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: 'white', whiteSpace: 'nowrap' }}>新建分析</span>
        </button>
        <button style={{ height: 38, borderRadius: 100, background: 'white', border: '1px solid #e4e7ec', padding: '0 20px', display: 'flex', alignItems: 'center', flexShrink: 0 }}>
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: '#111827', whiteSpace: 'nowrap' }}>最新匹配变化</span>
        </button>
        <button onClick={onAnalysisClick} style={{ height: 38, borderRadius: 100, background: 'white', border: '1px solid #e4e7ec', padding: '0 16px', display: 'flex', alignItems: 'center', flexShrink: 0 }}>
          <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: '#111827', whiteSpace: 'nowrap' }}>查看全部</span>
        </button>
      </div>

      {/* 岗位匹配变化 Card */}
      <div style={{ borderRadius: 24, background: 'rgba(255,255,255,0.68)', border: '1.217px solid rgba(255,255,255,0.55)', backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)', boxShadow: '0px 8px 32px 0px rgba(79,126,245,0.08)' }}>
        <div style={{ padding: 20 }}>
          <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 16, color: '#111827', lineHeight: '24px', marginBottom: 0 }}>岗位匹配变化</p>
          <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 0 }}>
            {JOBS.map((job, i) => (
              <div key={job.rank}>
                {/* Row */}
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <span style={{ fontFamily: "'Roboto:Regular', sans-serif", fontWeight: 400, fontSize: 15, color: '#000', width: 28, textAlign: 'center', flexShrink: 0, fontVariationSettings: '"wdth" 100' }}>{rankEmoji(job.rank)}</span>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 6 }}>
                      <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: '#111827', lineHeight: '21px' }}>{job.title}</p>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8, paddingLeft: 8 }}>
                        <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 14, fontVariationSettings: '"wdth" 100', backgroundImage: 'linear-gradient(142deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' }}>{job.match}%</span>
                        <div style={{ borderRadius: 99, padding: '2px 8px', background: job.delta > 0 ? 'rgba(52,199,89,0.12)' : 'rgba(107,114,128,0.1)' }}>
                          <span style={{ fontFamily: "'Roboto:SemiBold', sans-serif", fontWeight: 600, fontSize: 11, color: job.delta > 0 ? '#34c759' : '#6b7280', fontVariationSettings: '"wdth" 100' }}>
                            {job.delta > 0 ? `↑ +${job.delta}%` : '—'}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div style={{ height: 6, borderRadius: 99, background: 'rgba(229,231,235,0.8)', overflow: 'hidden' }}>
                      <div style={{ height: '100%', borderRadius: 99, backgroundImage: 'linear-gradient(178deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', width: `${job.match}%` }}/>
                    </div>
                  </div>
                </div>
                {i < JOBS.length - 1 && <div style={{ height: 1, background: 'rgba(229,231,235,0.7)', marginTop: 12, marginLeft: 40 }}/>}
                {i < JOBS.length - 1 && <div style={{ height: 14 }}/>}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANALYSIS
// ═══════════════════════════════════════════════════════════════════════════════

// Analysis history data (shared between tabs)
const ANALYSIS_HISTORY = [
  {
    date: '2026.08.29', resume: 'Resume V3',
    jobs: [
      { title: 'AI 产品经理', pct: 86 },
      { title: '产品经理', pct: 82 },
      { title: '数据产品经理', pct: 74 },
      { title: '用户增长产品', pct: 68 },
    ],
    topMatch: 86, delta: '+8%',
  },
  {
    date: '2026.08.12', resume: 'Resume V2',
    jobs: [
      { title: 'AI 产品经理', pct: 78 },
      { title: '产品经理', pct: 75 },
      { title: '数据产品经理', pct: 70 },
    ],
    topMatch: 78, delta: '+5%',
  },
  {
    date: '2026.07.28', resume: 'Resume V2',
    jobs: [
      { title: '产品经理', pct: 73 },
      { title: '数据产品经理', pct: 68 },
    ],
    topMatch: 73, delta: null,
  },
];

function AnalysisHome({ trialCount, onShowDialog }: { trialCount: number; onShowDialog: (d: Dialog) => void }) {
  const { go } = useNav();
  const [tab, setTab] = useState<'new' | 'history'>('new');
  const remaining = 3 - trialCount;
  const [addingJD, setAddingJD] = useState(false);
  const [jdText, setJdText] = useState('');
  const [addingURL, setAddingURL] = useState(false);
  const [urlText, setUrlText] = useState('');
  const [extraJobs, setExtraJobs] = useState<string[]>([]);

  const allJobs = [...JOBS.map(j => j.title), ...extraJobs];

  const handleAddJD = () => {
    const name = jdText.trim().split('\n')[0].slice(0, 30) || '新目标岗位';
    setExtraJobs(prev => [...prev, name]);
    setJdText('');
    setAddingJD(false);
  };

  const handleAddURL = () => {
    const url = urlText.trim();
    const domain = url.replace(/^https?:\/\//, '').split('/')[0];
    const name = domain ? `岗位（${domain.replace('www.', '')}）` : '新目标岗位';
    setExtraJobs(prev => [...prev, name]);
    setUrlText('');
    setAddingURL(false);
  };

  const handleRemoveExtra = (idx: number) => {
    setExtraJobs(prev => prev.filter((_, i) => i !== idx));
  };

  const handleStart = () => {
    if (remaining === 0) { onShowDialog('quota-done'); return; }
    if (remaining === 1) { onShowDialog('last-trial'); return; }
    go('a-processing');
  };

  return (
    <div>
      {/* ── Sticky header + tab bar ── */}
      <div className="flex-shrink-0 px-5 pt-3 pb-3 sticky top-0 z-10" style={{ background: S.bg }}>
        <p className="text-[12px] font-medium" style={{ color: S.textSecondary }}>分析</p>
        <h1 className="text-[22px] font-bold mb-0.5" style={{ color: S.textPrimary }}>职业分析</h1>

        {/* Tab switcher */}
        <div className="flex mt-3 rounded-2xl p-1" style={{ background: 'rgba(79,126,245,0.08)' }}>
          {(['new', 'history'] as const).map(t => (
            <button
              key={t}
              className="flex-1 text-[13px] font-semibold transition-all active:scale-[0.97]"
              style={{
                height: 36, borderRadius: 14,
                background: tab === t ? 'white' : 'transparent',
                color: tab === t ? S.primaryBlue : S.textSecondary,
                boxShadow: tab === t ? '0 2px 8px rgba(79,126,245,0.12)' : 'none',
              }}
              onClick={() => setTab(t)}
            >
              {t === 'new' ? '新建分析' : '历史分析'}
            </button>
          ))}
        </div>
      </div>

      {/* ── Content ── */}
      <div className="px-5 space-y-4" style={{ paddingBottom: 104 }}>
        {tab === 'new' ? (
          <>
            <p className="text-[13px]" style={{ color: S.textSecondary }}>基于你的职业经历，看看你与目标岗位的距离。</p>

            {/* Resume card */}
            <Card className="p-4" style={{ cursor: 'pointer' }} onClick={() => go('resume-history')}>
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: S.primary }}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><rect x="4" y="2" width="16" height="20" rx="3" stroke="white" strokeWidth="1.8"/><path d="M8 8h8M8 12h8M8 16h5" stroke="white" strokeWidth="1.8" strokeLinecap="round"/></svg>
                  </div>
                  <div>
                    <p className="text-[14px] font-bold" style={{ color: S.textPrimary }}>当前简历</p>
                    <p className="text-[11px]" style={{ color: S.textSecondary }}>Resume V3 · 2026.08.27 更新</p>
                  </div>
                </div>
                <span className="text-[12px] font-semibold px-3 py-1.5 rounded-xl flex-shrink-0" style={{ background: 'rgba(79,126,245,0.10)', color: S.primaryBlue }}>更换</span>
              </div>
              <div className="flex gap-3">
                {[['5项', '核心能力'], ['4段', '经历'], ['6个', '项目']].map(([n, l]) => (
                  <div key={l} className="flex-1 rounded-xl py-2 text-center" style={{ background: 'rgba(79,126,245,0.06)' }}>
                    <p className="text-[14px] font-bold" style={gradText}>{n}</p>
                    <p className="text-[10px]" style={{ color: S.textSecondary }}>{l}</p>
                  </div>
                ))}
              </div>
            </Card>

            {/* Target jobs card */}
            <Card className="p-4">
              <div className="flex items-center justify-between mb-3">
                <div>
                  <p className="text-[14px] font-bold" style={{ color: S.textPrimary }}>目标岗位</p>
                  <p className="text-[11px]" style={{ color: S.textSecondary }}>已添加 {allJobs.length} 个目标岗位</p>
                </div>
              </div>

              {/* Job chips */}
              <div className="flex flex-wrap gap-2 mb-3">
                {JOBS.map(j => (
                  <span key={j.rank} className="text-[12px] font-medium px-3 py-1 rounded-full" style={{ background: 'rgba(79,126,245,0.08)', color: S.primaryBlue }}>{j.title}</span>
                ))}
                {extraJobs.map((name, idx) => (
                  <div key={idx} className="flex items-center gap-1 pl-3 pr-2 py-1 rounded-full" style={{ background: 'rgba(167,123,230,0.10)' }}>
                    <span className="text-[12px] font-medium" style={{ color: S.primaryPurple }}>{name}</span>
                    <button
                      onClick={() => handleRemoveExtra(idx)}
                      className="w-4 h-4 rounded-full flex items-center justify-center"
                      style={{ background: 'rgba(167,123,230,0.18)' }}
                    >
                      <svg width="8" height="8" viewBox="0 0 24 24" fill="none"><path d="M18 6L6 18M6 6l12 12" stroke={S.primaryPurple} strokeWidth="2.5" strokeLinecap="round"/></svg>
                    </button>
                  </div>
                ))}
              </div>

              {/* Inline JD paste form */}
              {addingJD ? (
                <div className="rounded-2xl overflow-hidden" style={{ border: '1.5px solid rgba(79,126,245,0.25)', background: 'rgba(79,126,245,0.03)' }}>
                  <div className="px-3 pt-3 pb-2">
                    <p className="text-[12px] font-semibold mb-2" style={{ color: S.primaryBlue }}>粘贴岗位 JD</p>
                    <textarea
                      autoFocus
                      value={jdText}
                      onChange={e => setJdText(e.target.value)}
                      placeholder={"粘贴招聘描述（JD）内容…\n\nCareerly 将自动提取岗位名称和要求，用于与你的简历进行匹配分析。"}
                      className="w-full text-[13px] leading-relaxed resize-none"
                      style={{ minHeight: 120, background: 'transparent', color: S.textPrimary, caretColor: S.primaryBlue }}
                    />
                  </div>
                  <div className="flex border-t" style={{ borderColor: 'rgba(79,126,245,0.12)' }}>
                    <button onClick={() => { setJdText(''); setAddingJD(false); }} className="flex-1 text-[13px] font-medium py-3" style={{ color: S.textSecondary }}>取消</button>
                    <div style={{ width: 1, background: 'rgba(79,126,245,0.12)' }}/>
                    <button onClick={handleAddJD} disabled={!jdText.trim()} className="flex-1 text-[13px] font-semibold py-3" style={{ color: jdText.trim() ? S.primaryBlue : 'rgba(156,163,175,0.6)' }}>添加岗位</button>
                  </div>
                </div>
              ) : (
                <button
                  className="w-full flex items-center justify-center gap-2 rounded-xl active:scale-[0.98] transition-transform"
                  style={{ height: 36, border: '1.5px dashed rgba(79,126,245,0.30)', color: S.primaryBlue }}
                  onClick={() => { setAddingURL(false); setAddingJD(true); }}
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke={S.primaryBlue} strokeWidth="2.2" strokeLinecap="round"/></svg>
                  <span className="text-[12px] font-semibold">粘贴 JD 添加岗位</span>
                </button>
              )}

              {/* Inline URL form */}
              {addingURL ? (
                <div className="mt-2 rounded-2xl overflow-hidden" style={{ border: '1.5px solid rgba(167,123,230,0.28)', background: 'rgba(167,123,230,0.04)' }}>
                  <div className="px-3 pt-3 pb-2">
                    <p className="text-[12px] font-semibold mb-2" style={{ color: S.primaryPurple }}>粘贴岗位链接</p>
                    <input
                      autoFocus
                      type="url"
                      value={urlText}
                      onChange={e => setUrlText(e.target.value)}
                      placeholder="https://www.zhipin.com/job/..."
                      className="w-full text-[13px]"
                      style={{ background: 'transparent', color: S.textPrimary, caretColor: S.primaryPurple }}
                    />
                    <p className="text-[11px] mt-2" style={{ color: 'rgba(156,163,175,0.8)' }}>支持 Boss 直聘、拉勾、智联、猎聘等主流招聘平台链接</p>
                  </div>
                  <div className="flex border-t" style={{ borderColor: 'rgba(167,123,230,0.15)' }}>
                    <button onClick={() => { setUrlText(''); setAddingURL(false); }} className="flex-1 text-[13px] font-medium py-3" style={{ color: S.textSecondary }}>取消</button>
                    <div style={{ width: 1, background: 'rgba(167,123,230,0.15)' }}/>
                    <button onClick={handleAddURL} disabled={!urlText.trim()} className="flex-1 text-[13px] font-semibold py-3" style={{ color: urlText.trim() ? S.primaryPurple : 'rgba(156,163,175,0.6)' }}>添加岗位</button>
                  </div>
                </div>
              ) : (
                <button
                  className="w-full flex items-center justify-center gap-2 rounded-xl active:scale-[0.98] transition-transform mt-2"
                  style={{ height: 36, border: '1.5px dashed rgba(167,123,230,0.28)', color: S.primaryPurple }}
                  onClick={() => { setAddingJD(false); setAddingURL(true); }}
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71" stroke={S.primaryPurple} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71" stroke={S.primaryPurple} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
                  <span className="text-[12px] font-semibold">粘贴岗位 URL</span>
                </button>
              )}
            </Card>

            {/* Trial bar */}
            <div className="rounded-2xl px-4 py-3" style={{ background: remaining > 0 ? 'rgba(79,126,245,0.06)' : 'rgba(255,59,48,0.06)', border: `1px solid ${remaining > 0 ? 'rgba(79,126,245,0.15)' : 'rgba(255,59,48,0.15)'}` }}>
              <div className="flex items-center justify-between mb-2">
                <p className="text-[13px] font-semibold" style={{ color: remaining > 0 ? S.primaryBlue : '#FF3B30' }}>
                  {remaining > 0 ? '免费体验' : '免费次数已用完'}
                </p>
                <span className="text-[13px] font-bold" style={{ color: remaining > 0 ? S.primaryBlue : '#FF3B30' }}>剩余 {remaining} / 3 次</span>
              </div>
              <div className="h-1.5 rounded-full overflow-hidden" style={{ background: 'rgba(229,231,235,0.8)' }}>
                <div className="h-full rounded-full transition-all" style={{ width: `${(remaining / 3) * 100}%`, background: remaining > 0 ? S.primary : '#FF3B30' }}/>
              </div>
            </div>

            {/* CTA */}
            <PrimaryBtn label={remaining > 0 ? `开始分析${allJobs.length > 0 ? `（${allJobs.length} 个岗位）` : ''}` : '升级 Careerly Pro'} onClick={handleStart}/>

            {/* Last analysis peek */}
            <button className="w-full text-left active:scale-[0.99] transition-transform" onClick={() => go('a-result')}>
              <div className="rounded-3xl p-4 relative overflow-hidden" style={{ background: S.primary }}>
                <div className="absolute -top-8 -right-8 w-32 h-32 rounded-full" style={{ background: 'rgba(255,255,255,0.08)' }}/>
                <div className="relative">
                  <p className="text-white/60 text-[11px] font-medium mb-1">最近一次分析</p>
                  <div className="flex items-start justify-between mb-2">
                    <p className="text-white font-bold text-[15px]">2026.08.27 · 4 个岗位</p>
                    <div className="text-right">
                      <p className="text-white font-bold" style={{ fontSize: 30, lineHeight: 1 }}>86%</p>
                      <p className="text-white/70 text-[11px] font-semibold">最高匹配 ↑+8%</p>
                    </div>
                  </div>
                  <span className="inline-block px-3 py-1 rounded-full text-[12px] font-semibold text-white" style={{ background: 'rgba(255,255,255,0.20)' }}>查看结果 →</span>
                </div>
              </div>
            </button>
          </>
        ) : (
          <>
            <p className="text-[13px]" style={{ color: S.textSecondary }}>记录你与不同目标岗位之间的变化。</p>
            {ANALYSIS_HISTORY.map((h, i) => (
              <button key={i} className="w-full text-left active:scale-[0.99] transition-transform" onClick={() => i === 0 ? go('a-result') : undefined}>
                <Card className="p-4">
                  {/* Date + badge */}
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <p className="text-[11px] font-medium" style={{ color: S.textSecondary }}>{h.date}</p>
                      <p className="text-[14px] font-bold mt-0.5" style={{ color: S.textPrimary }}>一次分析 · {h.jobs.length} 个岗位</p>
                    </div>
                    <div className="text-right">
                      <p className="text-[24px] font-bold leading-none" style={gradText}>{h.topMatch}%</p>
                      {h.delta && <p className="text-[11px] font-semibold mt-0.5" style={{ color: S.green }}>↑{h.delta}</p>}
                      <p className="text-[10px] mt-0.5" style={{ color: S.textSecondary }}>最高匹配</p>
                    </div>
                  </div>

                  {/* Job breakdown */}
                  <div className="space-y-2 mb-3">
                    {h.jobs.map(j => (
                      <div key={j.title} className="flex items-center gap-2">
                        <span className="text-[12px] font-medium flex-1" style={{ color: S.textPrimary }}>{j.title}</span>
                        <div className="w-20 h-1.5 rounded-full overflow-hidden" style={{ background: 'rgba(229,231,235,0.8)' }}>
                          <div className="h-full rounded-full" style={{ width: `${j.pct}%`, background: S.primary }}/>
                        </div>
                        <span className="text-[12px] font-bold w-9 text-right" style={{ color: S.primaryBlue }}>{j.pct}%</span>
                      </div>
                    ))}
                  </div>

                  {/* Footer */}
                  <div className="flex items-center justify-between pt-2" style={{ borderTop: `1px solid ${S.divider}` }}>
                    <span className="text-[11px] font-medium" style={{ color: S.textSecondary }}>{h.resume}</span>
                    {i === 0 && <span className="text-[12px] font-semibold" style={{ color: S.primaryBlue }}>查看本次分析 →</span>}
                  </div>
                </Card>
              </button>
            ))}
          </>
        )}
      </div>
    </div>
  );
}

// ─── A00 Analysis Start ──────────────────────────────────────────────────────
function AnalysisStartPage() {
  const { go, back } = useNav();
  const steps = ['上传简历', '添加目标岗位', 'AI 分析匹配', '找到能力 Gap'];
  return (
    <div className="flex flex-col h-full">
      <TopBar title="" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 flex flex-col">
        {/* Hero */}
        <div className="flex flex-col items-center pt-4 pb-6">
          {/* AI orb */}
          <div
            className="flex items-center justify-center mb-6"
            style={{ width: 80, height: 80, borderRadius: '50%', background: 'linear-gradient(135deg, #5B7CFA 0%, #9B5DE5 60%, #C084FC 100%)', boxShadow: '0 16px 48px rgba(91,124,250,0.35)', filter: 'drop-shadow(0 0 18px rgba(99,102,241,0.40))' }}
          >
            <svg width="36" height="36" viewBox="0 0 24 24" fill="none">
              <path d="M12 2L13.5 9.5L21 11L13.5 12.5L12 20L10.5 12.5L3 11L10.5 9.5L12 2Z" fill="white" fillOpacity="0.92"/>
              <circle cx="19" cy="5" r="1.5" fill="white" fillOpacity="0.55"/>
              <circle cx="5" cy="19" r="1" fill="white" fillOpacity="0.45"/>
            </svg>
          </div>
          <h1 style={{ fontSize: 24, fontWeight: 800, color: S.textPrimary, textAlign: 'center', lineHeight: '30px' }}>开始一次职业分析</h1>
          <p style={{ fontSize: 13, color: S.textSecondary, textAlign: 'center', marginTop: 8, lineHeight: '20px', maxWidth: 240 }}>
            上传你的简历，再告诉 Careerly 你想去哪里。
          </p>
        </div>

        {/* Steps */}
        <Card className="p-5 mb-6">
          <p style={{ fontSize: 12, fontWeight: 600, color: S.textSecondary, marginBottom: 16, textTransform: 'uppercase', letterSpacing: '0.5px' }}>分析流程</p>
          <div className="space-y-3">
            {steps.map((s, i) => (
              <div key={s} className="flex items-center gap-3">
                <div className="flex items-center justify-center flex-shrink-0" style={{ width: 28, height: 28, borderRadius: '50%', background: i < 2 ? S.primary : 'rgba(79,126,245,0.10)' }}>
                  <span style={{ fontSize: 12, fontWeight: 700, color: i < 2 ? 'white' : S.primaryBlue }}>
                    {i + 1}
                  </span>
                </div>
                <span style={{ fontSize: 14, fontWeight: i < 2 ? 600 : 400, color: i < 2 ? S.textPrimary : S.textSecondary }}>{s}</span>
              </div>
            ))}
          </div>
        </Card>

        <div className="flex-1"/>
        <PrimaryBtn label="开始分析" onClick={() => go('a-resume-step')}/>
      </div>
    </div>
  );
}

// ─── Merged Analysis Setup (Resume + JD + Confirm) ───────────────────────────
type JDState = 'none' | 'link' | 'text' | 'parsing' | 'parsed';

function AnalysisResumeStep({ onShowDialog, trialCount }: { onShowDialog: (d: Dialog) => void; trialCount: number }) {
  const { go, back } = useNav();
  const remaining = 3 - trialCount;
  const [jdState, setJdState] = useState<JDState>('none');
  const [jdText, setJdText] = useState('');
  const [linkText, setLinkText] = useState('');
  const [isParsing, setIsParsing] = useState(false);

  const handleParse = () => {
    setIsParsing(true);
    setTimeout(() => { setIsParsing(false); setJdState('parsed'); }, 1400);
  };

  const handleStart = () => {
    if (remaining === 0) { onShowDialog('quota-done'); return; }
    if (remaining === 1) { onShowDialog('last-trial'); return; }
    go('a-processing');
  };

  const parsedJob = { title: 'AI 产品经理', company: '示例科技', location: '深圳' };

  return (
    <div className="flex flex-col h-full">
      {/* Header — just back button + plain title */}
      <div className="flex items-center gap-3 px-5 pt-4 pb-2 flex-shrink-0">
        <button
          onClick={back}
          className="flex items-center justify-center active:scale-90 transition-transform"
          style={{ width: 32, height: 32, borderRadius: 10, ...S.glassLight }}
        >
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
            <path d="M15 18L9 12L15 6" stroke={S.textPrimary} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <span style={{ fontSize: 14, fontWeight: 600, color: S.textSecondary }}>返回</span>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-8 space-y-6">

        {/* ── Section 1: 上传简历 ── */}
        <section>
          <h2 style={{ fontSize: 20, fontWeight: 800, color: S.textPrimary, marginBottom: 4 }}>1. 上传简历</h2>
          <p style={{ fontSize: 13, color: S.textSecondary, lineHeight: '20px', marginBottom: 14 }}>
            Careerly 基于你的简历，分析你的能力匹配度。
          </p>

          {/* Resume card */}
          <Card className="p-4 mb-3">
            <div className="flex items-center gap-3 mb-3">
              <div className="flex items-center justify-center flex-shrink-0" style={{ width: 44, height: 44, borderRadius: 13, background: S.primary }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="4" y="2" width="16" height="20" rx="3" stroke="white" strokeWidth="1.7"/><path d="M8 8h8M8 12h8M8 16h5" stroke="white" strokeWidth="1.7" strokeLinecap="round"/></svg>
              </div>
              <div className="flex-1">
                <p style={{ fontSize: 14, fontWeight: 700, color: S.textPrimary }}>Resume V3</p>
                <p style={{ fontSize: 11, color: S.textSecondary, marginTop: 2 }}>更新于 2026.08.27</p>
              </div>
              <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full" style={{ background: 'rgba(52,199,89,0.12)' }}>
                <svg width="10" height="10" viewBox="0 0 12 12" fill="none"><path d="M2 6L5 9L10 3" stroke={S.green} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
                <span style={{ fontSize: 11, fontWeight: 600, color: S.green }}>已准备</span>
              </div>
            </div>
            <div className="grid grid-cols-4 gap-2" style={{ borderTop: `1px solid ${S.divider}`, paddingTop: 12 }}>
              {[{ n: '4段', l: '工作经历' }, { n: '6个', l: '项目' }, { n: '12项', l: '技能' }, { n: '3个', l: '奖项' }].map(a => (
                <div key={a.l} className="text-center">
                  <p style={{ fontSize: 13, fontWeight: 700, color: S.primaryBlue }}>{a.n}</p>
                  <p style={{ fontSize: 10, color: S.textSecondary, marginTop: 2 }}>{a.l}</p>
                </div>
              ))}
            </div>
          </Card>

          {/* Secondary action: swap resume */}
          <button
            className="w-full text-center rounded-2xl active:scale-[0.98] transition-transform"
            style={{ height: 42, border: `1.5px solid rgba(79,126,245,0.25)`, color: S.primaryBlue, fontSize: 13, fontWeight: 500, background: 'rgba(79,126,245,0.04)' }}
            onClick={() => go('resume-history')}
          >
            更换简历
          </button>
        </section>

        {/* ── Section 2: 输入岗位信息 ── */}
        <section>
          <h2 style={{ fontSize: 20, fontWeight: 800, color: S.textPrimary, marginBottom: 4 }}>2. 输入岗位信息</h2>
          <p style={{ fontSize: 13, color: S.textSecondary, lineHeight: '20px', marginBottom: 14 }}>
            粘贴目标岗位的招聘描述，Careerly 会帮你找到匹配度。
          </p>

          {/* If parsed — show result card */}
          {jdState === 'parsed' ? (
            <Card className="p-4">
              <div className="flex items-center gap-2 mb-3">
                <div className="w-5 h-5 rounded-full flex items-center justify-center" style={{ background: 'rgba(52,199,89,0.15)' }}>
                  <svg width="10" height="10" viewBox="0 0 12 12" fill="none"><path d="M2 6L5 9L10 3" stroke={S.green} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/></svg>
                </div>
                <span style={{ fontSize: 12, fontWeight: 600, color: S.green }}>已识别岗位</span>
              </div>
              <p style={{ fontSize: 16, fontWeight: 800, color: S.textPrimary }}>{parsedJob.title}</p>
              <p style={{ fontSize: 12, color: S.textSecondary, marginTop: 3 }}>{parsedJob.company} · {parsedJob.location}</p>
              <button
                className="w-full text-center mt-4 py-2 active:scale-[0.98]"
                onClick={() => { setJdState('none'); setJdText(''); }}
                style={{ fontSize: 12, color: S.textSecondary, textDecoration: 'underline', textUnderlineOffset: 3 }}
              >
                修改岗位信息
              </button>
            </Card>
          ) : (
            /* Choice cards */
            <Card className="overflow-hidden">
              {/* 岗位链接 */}
              <button
                className="w-full flex items-center gap-3 px-4 active:bg-black/[0.02] transition-colors"
                style={{ height: 58, borderBottom: `1px solid ${S.divider}` }}
                onClick={() => setJdState(jdState === 'link' ? 'none' : 'link')}
              >
                <div className="flex items-center justify-center flex-shrink-0" style={{ width: 34, height: 34, borderRadius: 10, background: 'rgba(79,126,245,0.09)' }}>
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" stroke={S.primaryBlue} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" stroke={S.primaryBlue} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
                </div>
                <div className="flex-1 text-left">
                  <p style={{ fontSize: 13, fontWeight: 600, color: S.textPrimary }}>岗位链接</p>
                  <p style={{ fontSize: 11, color: S.textSecondary }}>粘贴招聘平台岗位链接</p>
                </div>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" style={{ transform: jdState === 'link' ? 'rotate(90deg)' : 'none', transition: 'transform 0.2s' }}>
                  <path d="M9 18L15 12L9 6" stroke={S.textSecondary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              </button>

              {/* Link input expansion */}
              {jdState === 'link' && (
                <div className="px-4 py-3" style={{ borderBottom: `1px solid ${S.divider}`, background: 'rgba(79,126,245,0.02)' }}>
                  <input
                    value={linkText}
                    onChange={e => setLinkText(e.target.value)}
                    placeholder="https://..."
                    className="w-full text-[13px] rounded-xl px-3 py-2.5"
                    style={{ background: 'rgba(229,231,235,0.40)', color: S.textPrimary }}
                  />
                  <button
                    className="w-full mt-2 rounded-xl active:scale-[0.98] transition-transform"
                    style={{ height: 38, background: linkText.trim() ? S.primary : 'rgba(229,231,235,0.6)', color: linkText.trim() ? 'white' : S.textSecondary, fontSize: 13, fontWeight: 600 }}
                    onClick={() => linkText.trim() && handleParse()}
                  >
                    {isParsing ? '读取中…' : '读取岗位'}
                  </button>
                </div>
              )}

              {/* 粘贴 JD */}
              <button
                className="w-full flex items-center gap-3 px-4 active:bg-black/[0.02] transition-colors"
                style={{ height: 58 }}
                onClick={() => setJdState(jdState === 'text' ? 'none' : 'text')}
              >
                <div className="flex items-center justify-center flex-shrink-0" style={{ width: 34, height: 34, borderRadius: 10, background: 'rgba(167,123,230,0.10)' }}>
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><rect x="4" y="2" width="16" height="20" rx="3" stroke={S.primaryPurple} strokeWidth="1.8"/><path d="M8 8h8M8 12h8M8 16h5" stroke={S.primaryPurple} strokeWidth="1.8" strokeLinecap="round"/></svg>
                </div>
                <div className="flex-1 text-left">
                  <p style={{ fontSize: 13, fontWeight: 600, color: S.textPrimary }}>粘贴 JD</p>
                  <p style={{ fontSize: 11, color: S.textSecondary }}>粘贴完整岗位描述</p>
                </div>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" style={{ transform: jdState === 'text' ? 'rotate(90deg)' : 'none', transition: 'transform 0.2s' }}>
                  <path d="M9 18L15 12L9 6" stroke={S.textSecondary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              </button>

              {/* JD text expansion */}
              {jdState === 'text' && (
                <div className="px-4 py-3" style={{ background: 'rgba(167,123,230,0.02)' }}>
                  <div className="flex items-center justify-between mb-2">
                    <span style={{ fontSize: 11, color: S.textSecondary }}>岗位描述</span>
                    <span style={{ fontSize: 11, color: S.textSecondary }}>{jdText.length} / 5000</span>
                  </div>
                  <textarea
                    value={jdText}
                    onChange={e => setJdText(e.target.value)}
                    placeholder={'例如：\n\n我们正在招聘一名 AI 产品经理，\n负责 AI Agent 产品规划……'}
                    maxLength={5000}
                    className="w-full resize-none text-[13px] leading-relaxed rounded-xl px-3 py-2.5"
                    style={{ minHeight: 120, background: 'rgba(229,231,235,0.40)', color: S.textPrimary }}
                  />
                  {isParsing ? (
                    <div className="flex items-center gap-2 mt-2">
                      <div className="w-3.5 h-3.5 rounded-full border-2 animate-spin" style={{ borderColor: S.primaryBlue, borderTopColor: 'transparent' }}/>
                      <span style={{ fontSize: 12, color: S.primaryBlue }}>AI 正在识别岗位信息…</span>
                    </div>
                  ) : (
                    <button
                      className="w-full mt-2 rounded-xl active:scale-[0.98] transition-transform"
                      style={{ height: 38, background: jdText.trim() ? S.primary : 'rgba(229,231,235,0.6)', color: jdText.trim() ? 'white' : S.textSecondary, fontSize: 13, fontWeight: 600 }}
                      onClick={() => jdText.trim() && handleParse()}
                    >
                      识别岗位
                    </button>
                  )}
                </div>
              )}
            </Card>
          )}
        </section>

        {/* ── Deliverables + CTA ── */}
        <section className="space-y-3">
          <p style={{ fontSize: 12, color: S.textSecondary, lineHeight: '18px' }}>
            Careerly 将提取你的简历和目标岗位，分析你的能力匹配与成长空间。
          </p>

          <div className="rounded-2xl px-4 py-3" style={{ background: 'rgba(79,126,245,0.05)', border: '1px solid rgba(79,126,245,0.10)' }}>
            <p style={{ fontSize: 11, fontWeight: 600, color: S.primaryBlue, marginBottom: 8 }}>本次分析将为你生成</p>
            <div className="grid grid-cols-2 gap-y-2 gap-x-3">
              {['匹配度报告', '能力分析', '能力 Gap', '成长建议'].map(label => (
                <div key={label} className="flex items-center gap-1.5">
                  <svg width="13" height="13" viewBox="0 0 14 14" fill="none"><circle cx="7" cy="7" r="7" fill="rgba(79,126,245,0.15)"/><path d="M4 7L6.2 9.2L10 5" stroke={S.primaryBlue} strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
                  <span style={{ fontSize: 12, color: S.textPrimary, fontWeight: 500 }}>{label}</span>
                </div>
              ))}
            </div>
          </div>

          <PrimaryBtn label="开始分析" onClick={handleStart}/>
          <button
            onClick={back}
            className="w-full text-center py-2 active:opacity-70 transition-opacity"
            style={{ fontSize: 13, color: S.textSecondary }}
          >
            返回修改
          </button>
        </section>
      </div>
    </div>
  );
}

// ─── (Kept for NavScreen type compat, no longer in active flow) ───────────────
function AnalysisJDStep() { return null; }
function AnalysisConfirmPage(_: { onDone: () => void; onShowDialog: (d: Dialog) => void; trialCount: number }) { return null; }

function AnalysisResumePage() {
  const { back } = useNav();
  return (
    <div className="flex flex-col h-full">
      <TopBar title="我的简历" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        <div className="rounded-3xl p-5 relative overflow-hidden" style={{ background: S.primary }}>
          <div className="absolute -top-8 -right-8 w-32 h-32 rounded-full" style={{ background: 'rgba(255,255,255,0.08)' }}/>
          <div className="relative">
            <p className="text-white/60 text-[11px] font-medium uppercase tracking-widest mb-1">当前版本</p>
            <h2 className="text-white font-bold text-[22px] mb-1">Resume V3</h2>
            <p className="text-white/65 text-[13px]">产品经理 · 5 年经验</p>
            <p className="text-white/50 text-[11px] mt-1">2026.08.27 更新</p>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-3">
          {[['4段', '职业经历'], ['6个', '项目'], ['12项', '技能'], ['3个', '奖项']].map(([n, l]) => (
            <Card key={l} className="p-4 text-center">
              <p className="text-[26px] font-bold leading-none mb-1" style={gradText}>{n}</p>
              <p className="text-[12px]" style={{ color: S.textSecondary }}>{l}</p>
            </Card>
          ))}
        </div>
        <PrimaryBtn label="上传新版本"/>
        <SecondaryBtn label="查看简历详情"/>
        <h3 className="text-[15px] font-bold pt-2" style={{ color: S.textPrimary }}>历史版本</h3>
        {[{ v: 'V2', date: '2026.05.15', change: '补充用户研究案例' }, { v: 'V1', date: '2026.01.03', change: '首次创建' }].map(r => (
          <Card key={r.v} className="p-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: 'rgba(229,231,235,0.6)' }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><rect x="4" y="2" width="16" height="20" rx="3" stroke={S.textSecondary} strokeWidth="1.8"/><path d="M8 8h8M8 12h8M8 16h5" stroke={S.textSecondary} strokeWidth="1.8" strokeLinecap="round"/></svg>
              </div>
              <div className="flex-1">
                <p className="text-[14px] font-bold" style={{ color: S.textPrimary }}>Resume {r.v}</p>
                <p className="text-[11px]" style={{ color: S.textSecondary }}>{r.date} · {r.change}</p>
              </div>
              <span className="text-[11px] px-2.5 py-1 rounded-full" style={{ background: 'rgba(229,231,235,0.7)', color: S.textSecondary }}>归档</span>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

function AnalysisTargetsPage() {
  const { go, back } = useNav();
  return (
    <div className="flex flex-col h-full">
      <TopBar title="目标岗位" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        <div className="flex items-center justify-between">
          <p className="text-[13px]" style={{ color: S.textSecondary }}>你正在关注 {JOBS.length} 个岗位</p>
          <span className="text-[12px] font-semibold px-2.5 py-1 rounded-full" style={{ background: 'rgba(79,126,245,0.10)', color: S.primaryBlue }}>{JOBS.length} 个</span>
        </div>
        <div className="space-y-3">
          {JOBS.map(job => (
            <button key={job.rank} className="w-full text-left" onClick={() => go('a-job', { jobIndex: job.rank - 1 })}>
              <Card className="p-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: job.rank === 1 ? S.primary : 'rgba(79,126,245,0.08)' }}>
                    <span style={{ color: job.rank === 1 ? 'white' : S.primaryBlue, fontWeight: 700, fontSize: 13 }}>#{job.rank}</span>
                  </div>
                  <div className="flex-1">
                    <p className="text-[15px] font-bold" style={{ color: S.textPrimary }}>{job.title}</p>
                    <p className="text-[11px]" style={{ color: S.textSecondary }}>上次 {job.prev}% → 现在 {job.match}%</p>
                  </div>
                  <div className="text-right">
                    <p className="text-[20px] font-bold" style={gradText}>{job.match}%</p>
                    <TrendBadge delta={job.delta}/>
                  </div>
                </div>
              </Card>
            </button>
          ))}
        </div>
        <button className="w-full rounded-2xl py-3.5 flex items-center justify-center gap-2.5" style={{ border: '2px dashed rgba(79,126,245,0.30)', background: 'rgba(79,126,245,0.04)' }}>
          <span className="text-[18px] font-bold" style={{ color: S.primaryBlue }}>+</span>
          <span className="text-[14px] font-semibold" style={{ color: S.primaryBlue }}>添加目标岗位 JD</span>
        </button>
      </div>
    </div>
  );
}

function AnalysisProcessing({ onDone, onStop }: { onDone: () => void; onStop: () => void }) {
  const STEPS = [
    { label: '岗位需求解析', sub: 'AI 提取核心职责与技能要求', duration: 1300, pctEnd: 20 },
    { label: '简历信息解析', sub: 'AI 提取经历、项目与能力证据', duration: 1500, pctEnd: 40 },
    { label: '能力匹配分析', sub: '将简历能力与岗位要求深度匹配', duration: 2400, pctEnd: 75 },
    { label: '识别能力 Gap', sub: '分析与岗位要求之间的成长空间', duration: 1200, pctEnd: 90 },
    { label: '生成分析报告', sub: '整理匹配度、排名与改进建议', duration: 900, pctEnd: 100 },
  ];
  const TASK_MSGS = [
    '正在读取岗位需求信息…',
    '正在解析简历与项目经历…',
    '正在深度匹配岗位与简历…',
    '正在识别能力 Gap…',
    '正在生成分析报告…',
  ];
  const PCT_START = [0, 20, 40, 75, 90];

  const [step, setStep] = useState(0);
  const [progress, setProgress] = useState(1);
  const [done, setDone] = useState(false);
  const [showExit, setShowExit] = useState(false);

  // Advance step on timer
  useEffect(() => {
    if (step < STEPS.length) {
      const t = setTimeout(() => setStep(s => s + 1), STEPS[step].duration);
      return () => clearTimeout(t);
    } else {
      const t = setTimeout(() => setDone(true), 500);
      return () => clearTimeout(t);
    }
  }, [step]);

  // Animate progress within the current step
  useEffect(() => {
    if (step >= STEPS.length) return;
    const start = PCT_START[step];
    const end = STEPS[step].pctEnd;
    const duration = STEPS[step].duration;
    const tickMs = 40;
    const ticks = duration / tickMs;
    let tick = 0;
    const id = setInterval(() => {
      tick++;
      const frac = Math.min(1, tick / ticks);
      // Ease-out curve: fast start, slow end
      const eased = 1 - Math.pow(1 - frac, 2.2);
      setProgress(Math.round(start + (end - start) * eased));
      if (tick >= ticks) clearInterval(id);
    }, tickMs);
    return () => clearInterval(id);
  }, [step]);

  useEffect(() => {
    if (done) {
      setProgress(100);
      const t = setTimeout(onDone, 900);
      return () => clearTimeout(t);
    }
  }, [done, onDone]);

  const currentMsg = done ? '分析完成！' : TASK_MSGS[Math.min(step, TASK_MSGS.length - 1)];

  return (
    <div className="flex flex-col h-full" style={{ position: 'relative', background: S.bg }}>
      {/* Header */}
      <div className="flex items-center px-4 pt-4 pb-1 flex-shrink-0">
        <button
          onClick={() => { if (!done) setShowExit(true); }}
          className="w-9 h-9 flex items-center justify-center rounded-full"
          style={{ background: 'rgba(255,255,255,0.55)' }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path d="M19 12H5M5 12L12 19M5 12L12 5" stroke={S.textPrimary} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <div className="flex-1 text-center">
          <p className="text-[16px] font-bold" style={{ color: S.textPrimary }}>AI 正在分析</p>
        </div>
        <div className="w-9"/>
      </div>

      {/* Context chip */}
      <div className="flex justify-center py-2 flex-shrink-0">
        <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full" style={{ background: 'rgba(79,126,245,0.08)', border: '0.5px solid rgba(79,126,245,0.15)' }}>
          <span className="text-[11px]" style={{ color: S.textSecondary }}>正在分析</span>
          <span className="text-[11px] font-semibold" style={{ color: S.primaryBlue }}>1 份简历 × {JOBS.length} 个目标岗位</span>
        </div>
      </div>

      {/* Scrollable body */}
      <div className="flex-1 overflow-y-auto px-5 pb-6">
        {/* ── Orb zone ── */}
        <div className="flex flex-col items-center pt-3 pb-5">
          {/* Halo + orb container */}
          <div className="relative flex items-center justify-center" style={{ width: 188, height: 188 }}>
            {/* Outer halo rings */}
            <div
              className="absolute inset-0 rounded-full ai-halo"
              style={{ background: 'radial-gradient(circle, rgba(79,126,245,0.14) 0%, transparent 65%)' }}
            />
            <div
              className="absolute rounded-full ai-halo-2"
              style={{ inset: 20, background: 'radial-gradient(circle, rgba(167,123,230,0.16) 0%, transparent 65%)' }}
            />
            {/* Main orb */}
            <div
              className={done ? 'ai-orb-complete' : 'ai-orb'}
              style={{
                width: 132, height: 132, borderRadius: '50%',
                background: 'radial-gradient(ellipse at 38% 36%, rgba(196,168,246,0.97) 0%, rgba(110,148,248,0.92) 44%, rgba(79,126,245,0.88) 68%, rgba(140,175,255,0.72) 100%)',
                boxShadow: done
                  ? '0 0 64px rgba(79,126,245,0.55), 0 0 32px rgba(167,123,230,0.45), inset 0 3px 10px rgba(255,255,255,0.45)'
                  : '0 14px 44px rgba(79,126,245,0.28), 0 4px 18px rgba(167,123,230,0.18), inset 0 3px 10px rgba(255,255,255,0.38)',
                position: 'relative', overflow: 'hidden',
              }}
            >
              {/* Specular highlight */}
              <div style={{ position: 'absolute', top: 18, left: 22, width: 40, height: 26, borderRadius: '50%', background: 'rgba(255,255,255,0.42)', filter: 'blur(5px)' }}/>
              {/* Secondary shimmer */}
              <div style={{ position: 'absolute', bottom: 22, right: 20, width: 20, height: 14, borderRadius: '50%', background: 'rgba(255,255,255,0.18)', filter: 'blur(4px)' }}/>
            </div>
          </div>

          {/* Percentage */}
          <div className="flex items-end gap-0.5 mt-1 mb-1.5" style={{ lineHeight: 1 }}>
            <span className="text-[48px] font-bold tabular-nums" style={{ color: S.textPrimary, letterSpacing: '-2px' }}>
              {progress}
            </span>
            <span className="text-[22px] font-bold mb-1.5" style={{ color: S.textSecondary }}>%</span>
          </div>

          {/* Current task */}
          <p
            className="text-[13px] text-center"
            style={{ color: done ? S.green : S.textSecondary, fontWeight: done ? 600 : 400, transition: 'color 350ms', minHeight: 18 }}
          >
            {currentMsg}
          </p>
        </div>

        {/* ── Timeline card ── */}
        <div className="rounded-2xl overflow-hidden" style={{ background: 'rgba(255,255,255,0.62)', backdropFilter: 'blur(10px)', border: '1px solid rgba(255,255,255,0.65)' }}>
          <div className="px-5 pt-4 pb-1">
            <p className="text-[11px] font-semibold tracking-wide" style={{ color: S.textSecondary, letterSpacing: '0.04em' }}>分析进度</p>
          </div>
          <div className="px-5 pb-4 pt-1">
            {STEPS.map((st, i) => {
              const complete = i < step || done;
              const active = i === step && !done;
              const waiting = !complete && !active;
              const stepPct = active
                ? Math.max(0, Math.min(100, Math.round(((progress - PCT_START[i]) / (st.pctEnd - PCT_START[i])) * 100)))
                : complete ? 100 : 0;
              return (
                <div key={i} className="flex gap-3">
                  {/* Indicator column */}
                  <div className="flex flex-col items-center flex-shrink-0" style={{ width: 28 }}>
                    <div
                      className={active ? 'ai-step-pulse' : ''}
                      style={{
                        width: 28, height: 28, borderRadius: '50%',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                        background: complete ? 'rgba(52,199,89,0.14)' : active ? S.primary : 'rgba(229,231,235,0.55)',
                        transition: 'background 400ms',
                      }}
                    >
                      {complete
                        ? <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M5 13L9 17L19 7" stroke={S.green} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
                        : <span className="text-[11px] font-bold" style={{ color: active ? 'white' : 'rgba(156,163,175,0.75)' }}>{i + 1}</span>
                      }
                    </div>
                    {i < STEPS.length - 1 && (
                      <div style={{ width: 2, flex: 1, marginTop: 3, marginBottom: 3, minHeight: 20, borderRadius: 1, background: complete ? 'rgba(52,199,89,0.28)' : 'rgba(229,231,235,0.7)', transition: 'background 400ms' }}/>
                    )}
                  </div>

                  {/* Content column */}
                  <div className="flex-1" style={{ paddingBottom: i < STEPS.length - 1 ? 14 : 0 }}>
                    <div className="flex items-start justify-between gap-2">
                      <p className="text-[14px] font-semibold leading-snug" style={{ color: complete ? S.green : active ? S.textPrimary : S.textSecondary, transition: 'color 400ms' }}>
                        {st.label}
                      </p>
                      <span className="text-[10px] font-semibold flex-shrink-0 mt-0.5" style={{ color: complete ? S.green : active ? S.primaryBlue : 'rgba(185,186,190,1)', transition: 'color 400ms' }}>
                        {complete ? '已完成 · 100%' : active ? `进行中 · ${stepPct}%` : '等待中'}
                      </span>
                    </div>
                    <p className="text-[11px] mt-0.5 leading-relaxed" style={{ color: 'rgba(160,163,172,0.9)' }}>{st.sub}</p>
                    {active && (
                      <div className="mt-2 h-1 rounded-full overflow-hidden" style={{ background: 'rgba(229,231,235,0.7)' }}>
                        <div
                          className="h-full rounded-full"
                          style={{ width: `${stepPct}%`, background: S.primary, transition: 'width 300ms ease-out' }}
                        />
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Exit button */}
        {!done && (
          <div className="pt-4">
            <button
              onClick={() => setShowExit(true)}
              className="w-full text-[13px] font-medium"
              style={{ color: 'rgba(160,163,172,1)', height: 40, borderRadius: 99, background: 'rgba(0,0,0,0.03)' }}
            >
              退出分析
            </button>
          </div>
        )}
      </div>

      {/* Exit confirmation bottom sheet */}
      {showExit && (
        <div style={{ position: 'absolute', inset: 0, zIndex: 100 }}>
          <div
            style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.28)', backdropFilter: 'blur(3px)' }}
            onClick={() => setShowExit(false)}
          />
          <div
            className="absolute bottom-0 left-0 right-0 rounded-t-3xl px-6 pt-5 pb-8"
            style={{ background: 'white' }}
          >
            <div className="w-9 h-1 rounded-full mx-auto mb-5" style={{ background: 'rgba(229,231,235,0.9)' }}/>
            <h3 className="text-[17px] font-bold mb-2" style={{ color: S.textPrimary }}>正在分析中</h3>
            <p className="text-[13px] leading-relaxed mb-6" style={{ color: S.textSecondary }}>
              现在离开不会影响你的简历和岗位信息，但本次分析需要重新开始。
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowExit(false)}
                className="flex-1 font-semibold text-[14px]"
                style={{ height: 48, borderRadius: 99, background: S.primary, color: 'white' }}
              >
                继续分析
              </button>
              <button
                onClick={onStop}
                className="flex-1 font-semibold text-[14px]"
                style={{ height: 48, borderRadius: 99, background: 'rgba(0,0,0,0.04)', color: S.textSecondary }}
              >
                退出
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function AnalysisResult() {
  const { go, back } = useNav();
  const [showUpdateSheet, setShowUpdateSheet] = useState(false);
  const [activeTab, setActiveTab] = useState<'match' | 'gap' | 'update'>('match');
  const gaps = [
    { name: 'AI Agent 产品落地', yours: 68, target: 82 },
    { name: '商业化经验', yours: 64, target: 78 },
    { name: '数据分析', yours: 60, target: 72 },
  ];
  const checkItems = ['匹配度报告', '能力分析', '能力 Gap', '成长建议'];
  const gradText17 = { backgroundImage: 'linear-gradient(155deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', backgroundClip: 'text' };
  return (
    <div className="flex flex-col h-full" style={{ position: 'relative' }}>
      <TopBar title="分析结果" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: '#6b7280', lineHeight: '18px' }}>基于 Resume V3 · 2026.08.29 · 4 个目标岗位</p>

        {/* Summary Hero Card */}
        <div style={{ height: 175, borderRadius: 24, backgroundImage: 'linear-gradient(153deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', boxShadow: '0px 16px 40px 0px rgba(79,126,245,0.28)', position: 'relative', overflow: 'hidden' }}>
          {/* Decorative circle */}
          <div style={{ position: 'absolute', left: 238, top: -32, width: 144, height: 144, borderRadius: 99, background: 'rgba(255,255,255,0.08)', pointerEvents: 'none' }}/>
          {/* Bottom subtitle */}
          <p style={{ position: 'absolute', left: 23, bottom: 12, fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: 'rgba(255,255,255,0.55)', lineHeight: '16.5px' }}>你的产品规划、AI 项目经验与岗位高度匹配。</p>
          {/* Mid row: badge + download button */}
          <div style={{ position: 'absolute', left: 19, top: 45, right: 16, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ background: 'rgba(255,255,255,0.20)', borderRadius: 99, padding: '6px 12px' }}>
              <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 12, lineHeight: '18px' }}>
                <span style={{ color: 'white' }}>较上次 </span>
                <span style={{ color: '#b7f1ba' }}>↑ +8%</span>
              </span>
            </div>
            <button style={{ height: 30, borderRadius: 20, background: '#373b4d', padding: '0 16px', display: 'flex', alignItems: 'center' }}>
              <span style={{ fontFamily: "'Roboto:SemiBold', sans-serif", fontWeight: 600, fontSize: 14, color: 'white', fontVariationSettings: '"wdth" 100', whiteSpace: 'nowrap' }}>点击下载</span>
            </button>
          </div>
          {/* Frosted panel */}
          <div style={{ position: 'absolute', left: 0, right: 0, top: 81, height: 94, background: 'rgba(255,255,255,0.05)', border: '1.217px solid rgba(255,255,255,0.29)', borderRadius: 24, margin: '0 -2px' }}>
            <p style={{ position: 'absolute', left: 16, top: 12, fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 11, color: 'white', lineHeight: '16.5px' }}>本次分析为你生成</p>
            <div style={{ position: 'absolute', left: 16, top: 37, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px 12px', width: 316 }}>
              {checkItems.map((item, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <svg width="13" height="13" viewBox="0 0 12.9835 12.9835" fill="none">
                    <circle cx="6.49" cy="6.49" r="6.49" fill="white" fillOpacity="0.15"/>
                    <path d="M2.705 7.033L4.869 9.197L10.279 3.787" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.298"/>
                  </svg>
                  <span style={{ fontFamily: i === 2 ? "'Inter:Medium', sans-serif" : "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 12, color: 'white', lineHeight: '18px' }}>
                    {item === '能力 Gap' ? <><span style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif" }}>能力</span><span style={{ fontFamily: "'Roboto:Medium', sans-serif", fontVariationSettings: '"wdth" 100' }}> Gap</span></> : item}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Tab row */}
        <div style={{ display: 'flex', gap: 16, alignItems: 'center', height: 58, paddingTop: 13, paddingBottom: 13 }}>
          {([['match', '岗位匹配度'], ['gap', '成长空间'], ['update', '更新分析']] as const).map(([key, label]) => (
            <button key={key} onClick={() => { if (key === 'update') setShowUpdateSheet(true); else setActiveTab(key); }}
              style={{
                height: 32, borderRadius: 20, padding: '0 16px', flexShrink: 0,
                background: activeTab === key ? '#373b4d' : 'white',
                border: activeTab === key ? 'none' : '1px solid #eaeafa',
              }}>
              <span style={{
                fontFamily: activeTab === key ? "'Roboto:SemiBold', sans-serif" : "'Roboto:Medium', sans-serif",
                fontWeight: activeTab === key ? 600 : 500,
                fontSize: 14,
                color: activeTab === key ? 'white' : 'rgba(30,31,34,0.6)',
                fontVariationSettings: '"wdth" 100',
                whiteSpace: 'nowrap',
              }}>{label}</span>
            </button>
          ))}
        </div>

        {/* Job match list */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {JOBS.map((job, i) => (
            <button key={job.rank} className="w-full text-left"
              onClick={() => go('a-job', { jobIndex: i })}
              style={{ transition: 'transform 120ms ease' }}
              onPointerDown={e => (e.currentTarget.style.transform = 'scale(0.98)')}
              onPointerUp={e => (e.currentTarget.style.transform = 'scale(1)')}
              onPointerLeave={e => (e.currentTarget.style.transform = 'scale(1)')}
            >
              {i === 0 ? (
                /* #1 gradient card */
                <div style={{ height: 87, borderRadius: 16, backgroundImage: 'linear-gradient(166deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', position: 'relative', overflow: 'hidden' }}>
                  <div style={{ position: 'absolute', left: 278, top: -24, width: 96, height: 96, borderRadius: 99, background: 'rgba(255,255,255,0.08)', pointerEvents: 'none' }}/>
                  <div style={{ position: 'absolute', left: 16, top: 16, right: 16, display: 'flex', alignItems: 'center', gap: 12 }}>
                    {/* Rank badge */}
                    <div style={{ width: 40, height: 40, borderRadius: 12, background: 'rgba(255,255,255,0.22)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                      <span style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 13, color: 'white' }}>#1</span>
                    </div>
                    {/* Title area */}
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ height: 24, position: 'relative' }}>
                        <div style={{ background: 'rgba(255,255,255,0.20)', borderRadius: 99, padding: '1px 8px', display: 'inline-flex', alignItems: 'center' }}>
                          <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 10, color: 'white', lineHeight: '15px' }}>最佳匹配</span>
                        </div>
                      </div>
                      <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 16, color: 'white', lineHeight: '24px' }}>{job.title}</p>
                    </div>
                    {/* Match % */}
                    <div style={{ flexShrink: 0, textAlign: 'right' }}>
                      <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 26, color: 'white', lineHeight: '39px' }}>{job.match}%</p>
                      <p style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 11, color: 'rgba(255,255,255,0.75)', lineHeight: '16.5px' }}>↑ +{job.delta}%</p>
                    </div>
                  </div>
                </div>
              ) : (
                /* #2-#4 frosted glass cards */
                <div style={{ borderRadius: 24, background: 'rgba(255,255,255,0.68)', border: '1.188px solid rgba(255,255,255,0.55)', backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)', boxShadow: '0px 8px 32px 0px rgba(79,126,245,0.08)', padding: 16 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                    <div style={{ width: 40, height: 40, borderRadius: 12, background: 'rgba(79,126,245,0.08)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                      <span style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 13, color: '#4f7ef5' }}>#{job.rank}</span>
                    </div>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: '#111827', lineHeight: '22.5px' }}>{job.title}</p>
                      <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#6b7280', lineHeight: '16.5px' }}>{job.prev}% → {job.match}%</p>
                    </div>
                    <div style={{ flexShrink: 0, textAlign: 'right' }}>
                      <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 22, lineHeight: '22px', ...gradText17 }}>{job.match}%</p>
                      <div style={{ position: 'relative', height: 24 }}>
                        {job.delta > 0 ? (
                          <div style={{ background: 'rgba(52,199,89,0.12)', borderRadius: 99, padding: '1px 8px', display: 'inline-flex', marginTop: 4 }}>
                            <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 11, color: '#34c759' }}>↑ +{job.delta}%</span>
                          </div>
                        ) : (
                          <div style={{ background: 'rgba(107,114,128,0.1)', borderRadius: 99, padding: '1px 8px', display: 'inline-flex', marginTop: 4 }}>
                            <span style={{ fontFamily: "'Inter:Medium', sans-serif", fontWeight: 500, fontSize: 11, color: '#6b7280' }}>—</span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </button>
          ))}
        </div>

        {/* Growth Space */}
        <div style={{ borderRadius: 24, background: 'rgba(255,255,255,0.68)', border: '1.188px solid rgba(255,255,255,0.55)', backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)', boxShadow: '0px 8px 32px 0px rgba(79,126,245,0.08)', padding: 20 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
            {gaps.map((g, i) => (
              <div key={i} style={{ paddingTop: i > 0 ? 16 : 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
                  <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 13, color: '#111827', lineHeight: '19.5px' }}>{g.name}</span>
                  <span style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 12, color: '#ff9500', lineHeight: '18px' }}>{g.yours} / {g.target}</span>
                </div>
                <div style={{ height: 8, borderRadius: 99, background: 'rgba(229,231,235,0.8)', position: 'relative', overflow: 'hidden' }}>
                  <div style={{ position: 'absolute', top: 0, left: 0, height: '100%', borderRadius: 99, width: `${g.target}%`, background: 'rgba(255,149,0,0.20)' }}/>
                  <div className="bar-grow" style={{ position: 'absolute', top: 0, left: 0, height: '100%', borderRadius: 99, backgroundImage: 'linear-gradient(178deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', width: `${(g.yours / 100) * 100}%`, animationDelay: `${i * 80 + 200}ms` }}/>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Bottom actions */}
        <div style={{ display: 'flex', gap: 12, paddingTop: 0 }}>
          <button
            onClick={() => go('a-job', { jobIndex: 0 })}
            style={{ flex: 1, height: 50, borderRadius: 99, background: 'rgba(79,126,245,0.10)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
          >
            <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 14, color: '#4f7ef5', lineHeight: '21px' }}>查看最匹配岗位</span>
          </button>
          <button
            onClick={() => setShowUpdateSheet(true)}
            style={{ flex: 1, height: 50, borderRadius: 99, backgroundImage: 'linear-gradient(163.5deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0px 6px 10px rgba(79,126,245,0.32)' }}
          >
            <span style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: 'white', lineHeight: '21px' }}>更新分析</span>
          </button>
        </div>
      </div>

      {/* Update analysis bottom sheet */}
      {showUpdateSheet && (
        <div style={{ position: 'absolute', inset: 0, zIndex: 100 }}>
          <div
            style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.28)', backdropFilter: 'blur(3px)' }}
            onClick={() => setShowUpdateSheet(false)}
          />
          <div className="absolute bottom-0 left-0 right-0 rounded-t-3xl px-6 pt-5 pb-8" style={{ background: 'white' }}>
            <div className="w-9 h-1 rounded-full mx-auto mb-5" style={{ background: 'rgba(229,231,235,0.9)' }}/>
            <h3 className="text-[17px] font-bold mb-1" style={{ color: S.textPrimary }}>更新分析</h3>
            <p className="text-[13px] mb-5 leading-relaxed" style={{ color: S.textSecondary }}>
              选择更新方式，原分析结果不会被覆盖。
            </p>
            <div className="space-y-3 mb-5">
              <button
                onClick={() => { setShowUpdateSheet(false); go('analysis'); }}
                className="w-full text-left active:scale-[0.98] transition-transform"
              >
                <div className="flex items-start gap-3 p-4 rounded-2xl" style={{ background: 'rgba(79,126,245,0.07)', border: '1px solid rgba(79,126,245,0.15)' }}>
                  <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: S.primary }}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="white" strokeWidth="2.2" strokeLinecap="round"/></svg>
                  </div>
                  <div className="flex-1">
                    <p className="text-[14px] font-bold" style={{ color: S.textPrimary }}>增加目标岗位</p>
                    <p className="text-[12px] mt-0.5" style={{ color: S.textSecondary }}>在原有岗位基础上新增目标岗位，重新分析</p>
                  </div>
                </div>
              </button>
              <button
                onClick={() => { setShowUpdateSheet(false); go('a-processing'); }}
                className="w-full text-left active:scale-[0.98] transition-transform"
              >
                <div className="flex items-start gap-3 p-4 rounded-2xl" style={{ background: 'rgba(167,123,230,0.07)', border: '1px solid rgba(167,123,230,0.18)' }}>
                  <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: 'linear-gradient(135deg, #A77BE6, #7B5CCC)' }}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><rect x="4" y="2" width="16" height="20" rx="3" stroke="white" strokeWidth="1.8"/><path d="M8 8h8M8 12h8M8 16h5" stroke="white" strokeWidth="1.8" strokeLinecap="round"/></svg>
                  </div>
                  <div className="flex-1">
                    <p className="text-[14px] font-bold" style={{ color: S.textPrimary }}>更新简历后重新分析</p>
                    <p className="text-[12px] mt-0.5" style={{ color: S.textSecondary }}>使用最新简历 V3，保留原有岗位集合</p>
                  </div>
                </div>
              </button>
            </div>
            <button
              onClick={() => setShowUpdateSheet(false)}
              className="w-full text-[14px] font-medium"
              style={{ height: 46, borderRadius: 99, background: 'rgba(0,0,0,0.04)', color: S.textSecondary }}
            >
              取消
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function AnalysisJobDetailPage() {
  const { go, back, params } = useNav();
  const jobIndex = (params.jobIndex as number) ?? 0;
  const job = JOBS[jobIndex];
  const strengths = [{ name: '产品规划能力', score: 85 }, { name: 'AI 应用能力', score: 76 }, { name: '用户研究', score: 78 }, { name: '项目管理', score: 74 }];
  const gaps = [{ name: 'AI 技术深度理解', level: '关键 Gap' }, { name: '商业化经验', level: '关键 Gap' }, { name: '数据分析能力', level: '一般 Gap' }];

  return (
    <div className="flex flex-col h-full">
      <TopBar title={job.title} onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        {/* Hero */}
        <div className="rounded-3xl p-5 relative overflow-hidden" style={{ background: S.primary, boxShadow: '0 16px 40px rgba(79,126,245,0.28)' }}>
          <div className="absolute -top-8 -right-8 w-36 h-36 rounded-full" style={{ background: 'rgba(255,255,255,0.08)' }}/>
          <div className="relative">
            <p className="text-white/60 text-[11px] uppercase tracking-widest mb-1">岗位详情 · 排名 #{job.rank}</p>
            <h2 className="text-white font-bold text-[20px] mb-1">{job.title}</h2>
            <p className="text-white/55 text-[12px] mb-3">Gap {job.gap}%</p>
            <div className="flex items-end gap-4">
              <div>
                <div className="flex items-baseline gap-0.5">
                  <span className="text-white font-bold" style={{ fontSize: 50, lineHeight: 1 }}>{job.match}</span>
                  <span className="text-white/80 text-[20px] font-bold">%</span>
                </div>
                <p className="text-white/55 text-[12px]">匹配度</p>
              </div>
              <div className="flex-1 pb-1 space-y-1.5">
                <span className="inline-flex items-center px-3 py-1.5 rounded-full text-[12px] font-bold" style={{ background: 'rgba(255,255,255,0.20)', color: 'white' }}>较上次 ↑ {job.delta}%</span>
                <p className="text-white/55 text-[11px]">来自 {job.matchSource}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Why Match */}
        <Card className="p-5">
          <h3 className="text-[15px] font-bold mb-3" style={{ color: S.textPrimary }}>为什么匹配？</h3>
          {['产品规划', '用户研究', 'AI 项目经验'].map((s, i) => (
            <div key={i} className="flex items-center gap-2.5 py-1.5">
              <div className="w-5 h-5 rounded-full flex items-center justify-center" style={{ background: 'rgba(52,199,89,0.15)' }}>
                <svg width="10" height="10" viewBox="0 0 24 24" fill="none"><path d="M5 13L9 17L19 7" stroke={S.green} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </div>
              <span className="text-[13px]" style={{ color: S.textPrimary }}>{s}</span>
            </div>
          ))}
        </Card>

        {/* Strengths */}
        <Card className="p-5 stagger-item">
          <h3 className="text-[15px] font-bold mb-4" style={{ color: S.textPrimary }}>✅ 能力优势</h3>
          {strengths.map((s, i) => (
            <div key={s.name}>
              <div className="flex items-center justify-between py-3">
                <span className="text-[14px]" style={{ color: S.textPrimary }}>{s.name}</span>
                <div className="flex items-center gap-2">
                  <span className="text-[13px] font-bold" style={{ color: S.textPrimary }}>{s.score}</span>
                  <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full" style={{ background: 'rgba(52,199,89,0.12)', color: S.green }}>高匹配</span>
                </div>
              </div>
              {i < strengths.length - 1 && <Divider/>}
            </div>
          ))}
        </Card>

        {/* Gaps */}
        <Card className="p-5 stagger-item">
          <h3 className="text-[15px] font-bold mb-1" style={{ color: S.textPrimary }}>△ 成长空间</h3>
          <p className="text-[12px] mb-4" style={{ color: S.textSecondary }}>当前 Gap：{job.gap}%</p>
          {gaps.map((g, i) => (
            <div key={g.name}>
              <div className="flex items-center justify-between py-3">
                <span className="text-[14px]" style={{ color: S.textPrimary }}>{g.name}</span>
                <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full" style={g.level === '关键 Gap' ? { background: 'rgba(255,149,0,0.12)', color: S.orange } : { background: 'rgba(107,114,128,0.08)', color: S.textSecondary }}>{g.level}</span>
              </div>
              {i < gaps.length - 1 && <Divider/>}
            </div>
          ))}
        </Card>

        <div className="flex gap-3">
          <button onClick={() => go('a-gap', { jobIndex })} className="flex-1 font-bold text-[14px] flex items-center justify-center" style={{ background: S.primary, borderRadius: 99, height: 48, color: 'white' }}>查看 Gap →</button>
          <button onClick={() => go('ai')} className="flex-1 font-bold text-[14px] flex items-center justify-center" style={{ background: 'rgba(79,126,245,0.10)', color: S.primaryBlue, borderRadius: 99, height: 48 }}>问问 AI</button>
        </div>
      </div>
    </div>
  );
}

function AnalysisGapPage() {
  const { back, params } = useNav();
  const jobIndex = (params.jobIndex as number) ?? 0;
  const job = JOBS[jobIndex];
  const gaps = [
    { name: 'AI Agent 产品落地', yours: 68, target: 82, gap: 14, why: '当前简历中缺少完整 AI Agent 项目的落地结果和产品指标数据。', actions: ['完成一个可实际运行的 AI Agent 项目', '补充需求分析与产品设计文档', '了解 LLM API 基础调用与 Prompt Engineering', '将项目成果沉淀为可展示的项目经历'] },
    { name: '商业化经验', yours: 64, target: 78, gap: 14, why: '缺少产品商业模式设计和 GMV / 营收相关数字。', actions: ['在简历中补充业务目标与商业结果', '了解 SaaS 定价和增长模型'] },
  ];
  return (
    <div className="flex flex-col h-full">
      <TopBar title="成长空间" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        <div className="rounded-2xl p-4" style={{ background: 'rgba(255,149,0,0.08)', border: '1px solid rgba(255,149,0,0.18)' }}>
          <p className="text-[12px] font-semibold mb-0.5" style={{ color: S.orange }}>目标岗位</p>
          <p className="text-[16px] font-bold" style={{ color: S.textPrimary }}>{job.title}</p>
          <p className="text-[12px] mt-1" style={{ color: S.textSecondary }}>当前 Gap：{job.gap}%</p>
        </div>

        <p className="text-[13px] leading-relaxed px-1" style={{ color: S.textSecondary }}>
          Gap 不是「缺点」，而是你当前能力与目标之间的成长空间。
        </p>

        {gaps.map((g, gi) => (
          <Card key={gi} className={`p-5 stagger-item`} style={{ animationDelay: `${gi * 80 + 60}ms` } as React.CSSProperties}>
            <div className="flex items-start justify-between mb-3">
              <h3 className="text-[15px] font-bold" style={{ color: S.textPrimary }}>{g.name}</h3>
              <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full flex-shrink-0 ml-2" style={{ background: 'rgba(255,149,0,0.12)', color: S.orange }}>关键 Gap</span>
            </div>
            <div className="flex gap-4 mb-3">
              {[{ label: '你的能力', val: g.yours }, { label: '岗位要求', val: g.target }, { label: 'Gap', val: g.gap }].map(item => (
                <div key={item.label} className="flex-1 text-center py-2.5 rounded-xl" style={{ background: 'rgba(79,126,245,0.06)' }}>
                  <p className="text-[18px] font-bold" style={item.label === 'Gap' ? { color: S.orange } : gradText}>{item.val}</p>
                  <p className="text-[10px] mt-0.5" style={{ color: S.textSecondary }}>{item.label}</p>
                </div>
              ))}
            </div>
            <p className="text-[12px] mb-3 leading-relaxed" style={{ color: S.textSecondary }}>{g.why}</p>
            <Divider/>
            <p className="text-[12px] font-semibold mt-3 mb-2" style={{ color: S.textPrimary }}>如何缩小？</p>
            {g.actions.map((a, i) => (
              <div key={i} className="flex items-start gap-2.5 py-1.5">
                <div className="w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5" style={{ background: S.primary }}>
                  <span className="text-white text-[10px] font-bold">{i + 1}</span>
                </div>
                <p className="text-[13px] leading-relaxed" style={{ color: S.textPrimary }}>{a}</p>
              </div>
            ))}
          </Card>
        ))}

        <PrimaryBtn label="和 AI 深入讨论 →"/>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// AI
// ═══════════════════════════════════════════════════════════════════════════════

const SUGGEST_QS = [
  '为什么这个岗位匹配度只有 82%？',
  '帮我优化这个项目的描述',
  '我目前最需要提升什么能力？',
  '下一步我应该做什么？',
];
const AI_REPLIES: Record<string, string> = {
  '为什么这个岗位匹配度只有 82%？': '产品经理岗位目前匹配度 82%，差距主要来自：\n\n① 数据分析能力（60分）低于岗位要求\n② 缺少 B 端产品独立负责案例\n\n你的产品规划（85分）和用户研究（78分）已是优势。',
  '帮我优化这个项目的描述': '建议按 STAR 结构优化：\n\n情景 → 任务 → 行动 → 结果\n\n例如：「主导 AI 招聘助手从 0 到 1 上线，月均处理简历 3000+，招聘效率提升 60%」\n\n重点突出数字和业务结果。',
  '我目前最需要提升什么能力？': 'AI 应用能力（当前 76 分）是最值得优先提升的。原因：\n\n✦ 影响你最高匹配岗位（AI 产品经理）\n✦ 当前已有基础，提升空间大\n✦ 可以通过具体项目快速形成职业资产',
  '下一步我应该做什么？': '建议按以下顺序行动：\n\n1. 选择一个 AI Agent 场景，完成完整产品设计\n2. 落地实现并记录需求分析过程\n3. 将项目经历更新至简历\n4. 重新分析，观察匹配度变化',
  '我的主要 Gap 是什么？': '基于当前分析，你的主要 Gap 有 2 项：\n\n① AI 技术深度理解 — 关键 Gap\n② 商业化经验 — 关键 Gap\n\n建议优先补充 AI Agent 项目落地经验。',
  '哪个能力最值得提升？': 'AI 应用能力（当前 76 分）最值得优先提升。\n\n✦ 影响最高匹配岗位（AI 产品经理）\n✦ 提升空间大，可通过项目快速积累',
};

/* ── AI page shared header ── */
const aiAssets = {
  backIcon: '/assets/454b8.svg',
  userIcon: '/assets/e920a.svg',
  arrowIcon: '/assets/18d52.svg',
  sendIcon: '/assets/e48de.svg',
};

function AIHeader({ onBack, onHistory }: { onBack?: () => void; onHistory?: () => void }) {
  return (
    <div
      className="flex items-center justify-between flex-shrink-0"
      style={{ padding: '16px 20px 12px' }}
    >
      {/* Left: back/close — glass rounded-[12px] 36px */}
      <button
        onClick={onBack}
        className="flex items-center justify-center active:scale-90 transition-transform"
        style={{
          width: 36, height: 36,
          borderRadius: 12,
          background: 'rgba(255,255,255,0.45)',
          border: '1.2px solid rgba(255,255,255,0.70)',
          backdropFilter: 'blur(12px)',
          WebkitBackdropFilter: 'blur(12px)',
          flexShrink: 0,
        }}
      >
        <img src={aiAssets.backIcon} alt="" width={18} height={18} style={{ display: 'block' }}/>
      </button>

      {/* Center */}
      <div className="flex flex-col items-center">
        <p style={{ fontFamily: "'Roboto:Bold', 'Roboto', sans-serif", fontWeight: 700, fontSize: 14, color: '#171827', lineHeight: '20px' }}>
          Career Copilot
        </p>
        <div className="flex items-center gap-1" style={{ paddingTop: 2 }}>
          <div style={{ width: 6, height: 6, borderRadius: '50%', background: '#00BC7D', boxShadow: '0 0 5px rgba(16,185,129,0.9)', flexShrink: 0 }}/>
          <p style={{ fontFamily: "'Plus Jakarta Sans:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#626579', lineHeight: '16.5px' }}>
            <span style={{ fontFamily: "'Roboto:Regular', sans-serif" }}>AI</span>
            <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif" }}>职业顾问</span>
            <span style={{ fontFamily: "'Roboto:Regular', sans-serif" }}>{` · `}</span>
            <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif" }}>在线</span>
          </p>
        </div>
      </div>

      {/* Right: chat history panel button */}
      <button
        onClick={onHistory}
        className="flex items-center justify-center active:scale-90 transition-transform"
        style={{
          width: 36, height: 36,
          borderRadius: 12,
          background: 'rgba(255,255,255,0.45)',
          border: '1.2px solid rgba(255,255,255,0.70)',
          backdropFilter: 'blur(12px)',
          WebkitBackdropFilter: 'blur(12px)',
          flexShrink: 0,
        }}
      >
        {/* Panel / history icon */}
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
          <rect x="3" y="3" width="18" height="18" rx="3" stroke="#635BDB" strokeWidth="1.7"/>
          <line x1="15" y1="3" x2="15" y2="21" stroke="#635BDB" strokeWidth="1.7" strokeLinecap="round"/>
          <line x1="8" y1="9" x2="12" y2="9" stroke="#635BDB" strokeWidth="1.5" strokeLinecap="round"/>
          <line x1="8" y1="12" x2="12" y2="12" stroke="#635BDB" strokeWidth="1.5" strokeLinecap="round"/>
          <line x1="8" y1="15" x2="12" y2="15" stroke="#635BDB" strokeWidth="1.5" strokeLinecap="round"/>
        </svg>
      </button>
    </div>
  );
}

/* ── AI input bar — matches Figma exactly ── */
function AIInputBar({ input, setInput, onSend, variant = 'chat' }: { input: string; setInput: (v: string) => void; onSend: (t: string) => void; variant?: 'welcome' | 'chat' }) {
  return (
    <div className="flex-shrink-0" style={{ padding: '0 33px 112px' }}>
      <div
        className="flex items-center gap-2.5"
        style={{
          height: 62,
          borderRadius: 99,
          background: 'rgba(255,255,255,0.72)',
          border: '1.2px solid rgba(255,255,255,0.88)',
          backdropFilter: 'blur(20px)',
          WebkitBackdropFilter: 'blur(20px)',
          boxShadow: '0 4px 24px rgba(91,124,250,0.13)',
          paddingLeft: 16,
          paddingRight: 16,
        }}
      >
        {variant === 'welcome' ? (
          /* Welcome state: "+" icon with vertical separator — matches Figma Frame SVG */
          <div className="flex items-center flex-shrink-0 gap-0" style={{ height: 32 }}>
            <div className="flex items-center justify-center" style={{ width: 33, height: 32 }}>
              <svg width="34" height="32" viewBox="0 0 33.818 31.993" fill="none">
                <path d="M16.909 4.747V27.247M5.159 15.997H28.659" stroke="#D3CEF4" strokeLinecap="round" strokeWidth="1.65"/>
                <path d="M32.993 4.747V27.247" stroke="#D3CEF4" strokeLinecap="round" strokeOpacity="0.5" strokeWidth="1.65"/>
              </svg>
            </div>
          </div>
        ) : (
          /* Chat state: small ∞ in gradient square */
          <div
            className="flex items-center justify-center flex-shrink-0"
            style={{ width: 32, height: 32, borderRadius: 12, background: 'rgba(99,91,219,0.08)' }}
          >
            <span style={{ fontFamily: "'Roboto:Regular', 'Roboto', sans-serif", fontSize: 16, fontWeight: 400, color: '#635BDB', lineHeight: 1 }}>∞</span>
          </div>
        )}

        {/* Input */}
        <div className="flex-1 min-w-0 overflow-hidden" style={{ height: 16 }}>
          <input
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter') onSend(input); }}
            placeholder="输入你想问的问题..."
            className="w-full bg-transparent outline-none"
            style={{
              fontFamily: "'Plus Jakarta Sans:Regular', 'Plus Jakarta Sans', sans-serif",
              fontWeight: 400,
              fontSize: 12,
              color: S.textPrimary,
              lineHeight: 'normal',
            }}
          />
        </div>

        {/* Send button */}
        <button
          onClick={() => onSend(input)}
          className="flex items-center justify-center flex-shrink-0 active:scale-90 transition-transform"
          style={{
            width: 36, height: 36,
            borderRadius: 12,
            background: input.trim() ? 'linear-gradient(135deg, #5B7CFA 0%, #9B5DE5 100%)' : 'rgba(99,91,219,0.10)',
          }}
        >
          <svg width="16" height="16" viewBox="0 0 11.99 9.992" fill="none" style={{ display: 'block', opacity: input.trim() ? 1 : 0.5 }}>
            <path d="M1 5l9.99-4L7 9.992 5.5 6 1 5z" fill="#635BDB" fillOpacity={input.trim() ? 0 : 0.4}/>
            <path d="M1 5l9.99-4L7 9.992 5.5 6 1 5z" fill="white" fillOpacity={input.trim() ? 0.9 : 0}/>
          </svg>
        </button>
      </div>
    </div>
  );
}

function AIHistoryDrawer({ open, onClose, onSelect }: { open: boolean; onClose: () => void; onSelect: (id: number) => void }) {
  const TAG_COLORS: Record<string, string> = {
    '86%': '#4F7EF5', '82%': '#A77BE6', '简历': '#34C759', '能力': '#FF9500', '规划': '#635BDB',
  };
  return (
    <>
      {/* Backdrop */}
      <div
        className="absolute inset-0 z-40 transition-opacity duration-300"
        style={{ background: 'rgba(0,0,0,0.30)', backdropFilter: 'blur(2px)', opacity: open ? 1 : 0, pointerEvents: open ? 'auto' : 'none' }}
        onClick={onClose}
      />
      {/* Side panel slides in from right */}
      <div
        className="absolute top-0 bottom-0 right-0 z-50 flex flex-col"
        style={{
          width: '78%',
          background: 'linear-gradient(160deg, rgba(230,235,255,0.97) 0%, rgba(240,230,255,0.97) 100%)',
          backdropFilter: 'blur(32px)',
          WebkitBackdropFilter: 'blur(32px)',
          borderLeft: '1px solid rgba(255,255,255,0.70)',
          boxShadow: '-8px 0 40px rgba(91,124,250,0.18)',
          transform: open ? 'translateX(0)' : 'translateX(100%)',
          transition: 'transform 0.30s cubic-bezier(0.32,0.72,0,1)',
        }}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-5 pt-5 pb-4 flex-shrink-0">
          <p style={{ fontFamily: "'Roboto:Bold', 'Roboto', sans-serif", fontWeight: 700, fontSize: 15, color: '#171827' }}>聊天记录</p>
          <button
            onClick={onClose}
            className="flex items-center justify-center active:scale-90 transition-transform"
            style={{ width: 30, height: 30, borderRadius: 10, background: 'rgba(99,91,219,0.10)' }}
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
              <path d="M18 6L6 18M6 6l12 12" stroke="#635BDB" strokeWidth="2.2" strokeLinecap="round"/>
            </svg>
          </button>
        </div>

        {/* New chat button */}
        <div className="px-4 pb-3 flex-shrink-0">
          <button
            className="w-full flex items-center justify-center gap-2 active:scale-[0.98] transition-transform"
            style={{ height: 42, borderRadius: 14, background: 'linear-gradient(135deg, #5B7CFA 0%, #9B5DE5 100%)', boxShadow: '0 4px 16px rgba(91,124,250,0.30)' }}
            onClick={onClose}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="white" strokeWidth="2.2" strokeLinecap="round"/></svg>
            <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 13, color: 'white' }}>新建对话</span>
          </button>
        </div>

        {/* Divider */}
        <div style={{ height: 1, marginLeft: 16, marginRight: 16, background: 'rgba(99,91,219,0.10)', flexShrink: 0 }}/>

        {/* History list */}
        <div className="flex-1 overflow-y-auto px-3 py-3 space-y-2">
          {CHAT_HISTORY.map((item, i) => (
            <button
              key={item.id}
              onClick={() => onSelect(item.id)}
              className="w-full text-left flex items-start gap-3 active:scale-[0.98] transition-transform"
              style={{
                padding: '12px 14px',
                borderRadius: 16,
                background: i === 0 ? 'rgba(91,124,250,0.10)' : 'rgba(255,255,255,0.60)',
                border: i === 0 ? '1px solid rgba(91,124,250,0.18)' : '1px solid rgba(255,255,255,0.80)',
                backdropFilter: 'blur(8px)',
              }}
            >
              {/* Icon */}
              <div className="flex items-center justify-center flex-shrink-0 mt-0.5"
                style={{ width: 30, height: 30, borderRadius: 10, background: i === 0 ? 'rgba(91,124,250,0.15)' : 'rgba(99,91,219,0.08)' }}>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                  <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z" stroke="#635BDB" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-1 mb-0.5">
                  <p className="truncate" style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 12, color: '#171827' }}>{item.title}</p>
                  <span style={{ fontFamily: "'Roboto:Regular', sans-serif", fontSize: 10, color: '#9ca3af', flexShrink: 0 }}>{item.date}</span>
                </div>
                <p className="truncate" style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#6b7280' }}>{item.preview}</p>
                <div className="mt-1.5">
                  <span style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 10, color: TAG_COLORS[item.tag] ?? '#635BDB', background: `${TAG_COLORS[item.tag] ?? '#635BDB'}18`, padding: '1px 7px', borderRadius: 99 }}>{item.tag}</span>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>
    </>
  );
}

const CHAT_HISTORY = [
  { id: 1, title: 'AI 产品经理匹配分析', preview: '你在 AI 产品经理方向匹配度达 86%…', date: '今天', tag: '86%' },
  { id: 2, title: '简历优化建议', preview: '建议按 STAR 结构优化项目描述…', date: '昨天', tag: '简历' },
  { id: 3, title: '能力提升路径', preview: 'AI 应用能力（当前 76 分）是最值得…', date: '9月12日', tag: '能力' },
  { id: 4, title: '产品经理岗位差距', preview: '产品经理岗位目前匹配度 82%，差距…', date: '9月10日', tag: '82%' },
  { id: 5, title: '下一步行动计划', preview: '建议按以下顺序行动：选择一个 AI…', date: '9月5日', tag: '规划' },
];

function AIPage({ messages, setMessages }: { messages: Message[]; setMessages: React.Dispatch<React.SetStateAction<Message[]>> }) {
  const [input, setInput] = useState('');
  const [showHistory, setShowHistory] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);
  const hasChat = messages.some(m => m.role === 'user');

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior: 'smooth' }); }, [messages]);

  const handleSend = (text: string) => {
    if (!text.trim()) return;
    setMessages(prev => [...prev, { role: 'user', text: text.trim() }]);
    if (text === input) setInput('');
    setTimeout(() => {
      const reply = AI_REPLIES[text] ?? '收到！基于你当前的职业数据，我正在为你分析。让我针对这个问题深入解读一下...';
      setMessages(prev => [...prev, { role: 'ai', text: reply }]);
    }, 700);
  };

  /* ════════ Welcome / empty state ════════ */
  if (!hasChat) {
    return (
      <div className="flex flex-col h-full relative">
        <AIHeader onBack={() => {/* no-op on welcome */}} onHistory={() => setShowHistory(true)}/>

        {/* Glass card — matches Figma: mx-16px, rounded-24px, glass inner blur */}
        <div
          className="flex-1 mx-4 overflow-hidden flex flex-col"
          style={{
            borderRadius: 24,
            border: '1.2px solid rgba(255,255,255,0.82)',
            boxShadow: '0 8px 40px rgba(91,124,250,0.16)',
            position: 'relative',
          }}
        >
          {/* Inner glass backdrop */}
          <div
            className="absolute inset-0 pointer-events-none"
            style={{
              borderRadius: 24,
              background: 'rgba(255,255,255,0.58)',
              backdropFilter: 'blur(28px)',
              WebkitBackdropFilter: 'blur(28px)',
            }}
          />
          {/* Inner highlight ring */}
          <div
            className="absolute inset-0 pointer-events-none rounded-[24px]"
            style={{ boxShadow: 'inset 0px 1.5px 0px 0px rgba(255,255,255,0.90)' }}
          />

          {/* Scrollable content */}
          <div className="relative z-10 flex-1 overflow-y-auto">
            {/* Avatar + greeting */}
            <div className="flex flex-col items-center pt-6 pb-5 px-5">
              {/* 88px gradient circle — pure, no symbol */}
              <div
                className="mb-4"
                style={{
                  width: 88, height: 88,
                  borderRadius: '50%',
                  background: 'linear-gradient(135deg, #5B7CFA 0%, #9B5DE5 60%, #C084FC 100%)',
                  boxShadow: '0px 0px 36.8px 0px rgba(99,102,241,0.59)',
                  flexShrink: 0,
                }}
              />

              <p style={{ fontSize: 16, color: '#171827', lineHeight: '24px', textAlign: 'center' }}>
                <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 900 }}>你好，</span>
                <span style={{ fontFamily: "'Plus Jakarta Sans:ExtraBold', sans-serif", fontWeight: 800 }}>ALEX</span>
              </p>
              <p style={{ fontSize: 12, color: '#626579', lineHeight: '19.5px', textAlign: 'center', paddingTop: 6, maxWidth: 220 }}>
                <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400 }}>我是你的</span>
                <span style={{ fontFamily: "'Roboto:Regular', sans-serif", fontWeight: 400 }}>{` AI `}</span>
                <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif", fontWeight: 400 }}>职业顾问，可以帮你分析岗位、优化简历、制定求职策略。</span>
              </p>
            </div>

            {/* Divider */}
            <div style={{ height: 0, marginLeft: 20, marginRight: 20, borderTop: '1px solid rgba(99,91,219,0.10)' }}/>

            {/* Suggestion section */}
            <div className="px-5 pt-4 pb-5">
              <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 11, color: '#9CA3AF', letterSpacing: '0.275px', textTransform: 'uppercase', paddingLeft: 4, paddingBottom: 12 }}>
                你可以问我
              </p>
              <div className="flex flex-col gap-2">
                {SUGGEST_QS.map(q => (
                  <button
                    key={q}
                    onClick={() => handleSend(q)}
                    className="flex items-center text-left active:scale-[0.985] transition-transform"
                    style={{
                      background: 'rgba(255,255,255,0.70)',
                      border: '1.2px solid rgba(91,124,250,0.14)',
                      borderRadius: 16,
                      boxShadow: '0 2px 10px rgba(99,91,219,0.05)',
                      gap: 12,
                      padding: 14,
                      width: '100%',
                    }}
                  >
                    {/* Arrow icon in gradient square */}
                    <div
                      className="flex items-center justify-center flex-shrink-0"
                      style={{
                        width: 28, height: 28,
                        borderRadius: 12,
                        background: 'linear-gradient(135deg, rgba(91,124,250,0.10) 0%, rgba(155,93,229,0.10) 100%)',
                      }}
                    >
                      <img src={aiAssets.arrowIcon} alt="" width={13} height={13} style={{ display: 'block' }}/>
                    </div>
                    <span style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 12, color: '#171827', lineHeight: '16px' }}>
                      {q}
                    </span>
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        <AIInputBar input={input} setInput={setInput} onSend={handleSend} variant="welcome"/>
        <AIHistoryDrawer open={showHistory} onClose={() => setShowHistory(false)} onSelect={() => setShowHistory(false)}/>
      </div>
    );
  }

  /* ════════ Chat state ════════ */
  return (
    <div className="flex flex-col h-full relative">
      <AIHeader onBack={() => setMessages([])} onHistory={() => setShowHistory(true)}/>

      {/* Context chip */}
      <div className="flex-shrink-0 px-5 mb-2">
        <div
          className="inline-flex items-center gap-2 px-3"
          style={{ height: 28, borderRadius: 99, background: 'rgba(91,124,250,0.07)', border: '1px solid rgba(91,124,250,0.12)' }}
        >
          <div style={{ width: 6, height: 6, borderRadius: '50%', background: '#00BC7D', flexShrink: 0 }}/>
          <p style={{ fontSize: 11, color: '#5B7CFA' }}>
            <span style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500 }}>已关联分析：</span>
            <span style={{ fontFamily: "'Roboto:Medium', sans-serif", fontWeight: 500 }}>AI </span>
            <span style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500 }}>产品经理</span>
            <span style={{ fontFamily: "'Roboto:Medium', sans-serif", fontWeight: 500 }}>{` · 86% `}</span>
            <span style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500 }}>匹配</span>
          </p>
        </div>
      </div>

      {/* Message list */}
      <div className="flex-1 px-5 overflow-y-auto space-y-4 pb-4">
        {messages.map((msg, i) => (
          <div key={i} className={`flex gap-2.5 ${msg.role === 'user' ? 'flex-row-reverse' : 'items-end'}`}>
            {msg.role === 'ai' && (
              <div
                className="flex items-center justify-center flex-shrink-0"
                style={{
                  width: 32, height: 32,
                  borderRadius: '50%',
                  background: 'linear-gradient(135deg, #5B7CFA 0%, #9B5DE5 100%)',
                  filter: 'drop-shadow(0 2px 6px rgba(91,124,250,0.35))',
                }}
              >
                <span style={{ fontFamily: "'Roboto:Regular', 'Roboto', sans-serif", fontSize: 16, fontWeight: 400, color: 'white', lineHeight: 1 }}>∞</span>
              </div>
            )}
            <div
              className="max-w-[76%] px-4 py-3"
              style={msg.role === 'ai'
                ? { background: 'rgba(255,255,255,0.80)', border: '1px solid rgba(255,255,255,0.70)', backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)', borderRadius: '4px 18px 18px 18px', boxShadow: '0 2px 12px rgba(91,124,250,0.08)' }
                : { background: 'linear-gradient(135deg, #5B7CFA 0%, #9B5DE5 100%)', borderRadius: '18px 4px 18px 18px', boxShadow: '0 4px 16px rgba(91,124,250,0.30)' }}
            >
              <p
                style={{
                  fontFamily: "'Noto Sans SC:Regular', 'Plus Jakarta Sans:Regular', sans-serif",
                  fontWeight: 400, fontSize: 13, lineHeight: '20px',
                  color: msg.role === 'user' ? 'white' : S.textPrimary,
                  whiteSpace: 'pre-line',
                }}
              >
                {msg.text}
              </p>
            </div>
          </div>
        ))}
        <div ref={bottomRef}/>
      </div>

      <AIInputBar input={input} setInput={setInput} onSend={handleSend}/>
      <AIHistoryDrawer open={showHistory} onClose={() => setShowHistory(false)} onSelect={() => setShowHistory(false)}/>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// MY / PROFILE
// ═══════════════════════════════════════════════════════════════════════════════

// ── Growth calendar data ──────────────────────────────────────────────────────
type GrowthEventType = 'analysis' | 'resume' | 'project' | 'capability';
interface GrowthEvent {
  date: number; type: GrowthEventType;
  title: string; sub: string; tag?: string; delta?: string;
}
const GROWTH_EVENTS: GrowthEvent[] = [
  { date: 29, type: 'analysis', title: '完成职业分析', sub: 'AI 产品经理', tag: '86%', delta: '+8%' },
  { date: 27, type: 'resume', title: '更新简历 V3', sub: '新增 AI Agent 项目', tag: '产品规划 +5' },
  { date: 20, type: 'project', title: '新增 AI Agent 项目', sub: '产品负责人', tag: 'AI 能力 +8' },
  { date: 18, type: 'capability', title: 'AI 应用能力提升', sub: '68 → 76', delta: '+8' },
  { date: 12, type: 'analysis', title: '完成职业分析', sub: '产品经理', tag: '82%', delta: '+4%' },
  { date: 5, type: 'resume', title: '更新简历 V2', sub: '补充项目经历', tag: '产品规划 +3' },
];
const EVENT_COLORS: Record<GrowthEventType, string> = {
  analysis: '#4F7EF5', resume: '#A77BE6', project: '#34C759', capability: '#FF9500',
};
const EVENT_LABELS: Record<GrowthEventType, string> = {
  analysis: '分析', resume: '简历', project: '项目', capability: '能力',
};

// Aug 2026 starts on Saturday (index 5 in Mon-Sun grid)
const AUG_START_DOW = 5; // 0=Mon … 6=Sun
const AUG_DAYS = 31;
const WEEK_LABELS = ['一', '二', '三', '四', '五', '六', '日'];

function GrowthCalendar({ selectedDate, onSelect }: { selectedDate: number | null; onSelect: (d: number) => void }) {
  const activityDates = new Set(GROWTH_EVENTS.map(e => e.date));
  const eventsByDate = GROWTH_EVENTS.reduce<Record<number, GrowthEventType[]>>((acc, e) => {
    acc[e.date] = acc[e.date] ? [...acc[e.date], e.type] : [e.type];
    return acc;
  }, {});

  const cells: (number | null)[] = [
    ...Array(AUG_START_DOW).fill(null),
    ...Array.from({ length: AUG_DAYS }, (_, i) => i + 1),
  ];
  // pad to full rows
  while (cells.length % 7 !== 0) cells.push(null);

  return (
    <div>
      {/* Month header */}
      <div className="flex items-center justify-between mb-3">
        <span style={{ fontWeight: 600, fontSize: 13, color: S.textPrimary }}>2026年8月</span>
        <div className="flex gap-1">
          {(['分析', '简历', '项目', '能力'] as const).map((lbl, i) => {
            const t = (['analysis', 'resume', 'project', 'capability'] as GrowthEventType[])[i];
            return (
              <div key={lbl} className="flex items-center gap-0.5">
                <div className="w-1.5 h-1.5 rounded-full" style={{ background: EVENT_COLORS[t] }}/>
                <span style={{ fontSize: 9, color: S.textSecondary }}>{lbl}</span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Weekday labels */}
      <div className="grid grid-cols-7 mb-1">
        {WEEK_LABELS.map(d => (
          <div key={d} className="text-center" style={{ fontSize: 10, color: S.textSecondary, paddingBottom: 4 }}>{d}</div>
        ))}
      </div>

      {/* Day cells */}
      <div className="grid grid-cols-7 gap-y-1">
        {cells.map((day, i) => {
          if (!day) return <div key={i}/>;
          const isToday = day === 30;
          const isSelected = day === selectedDate;
          const hasActivity = activityDates.has(day);
          const types = eventsByDate[day] ?? [];
          return (
            <button
              key={i}
              onClick={() => hasActivity && onSelect(day)}
              className="flex flex-col items-center gap-0.5 py-1 transition-all active:scale-90"
              style={{ borderRadius: 8, background: isSelected ? S.primary : isToday ? 'rgba(79,126,245,0.08)' : 'transparent' }}
            >
              <span style={{
                fontSize: 12, fontWeight: isToday || isSelected ? 700 : 400,
                color: isSelected ? 'white' : isToday ? S.primaryBlue : S.textPrimary,
              }}>{day}</span>
              {hasActivity && (
                <div className="flex gap-0.5 justify-center">
                  {types.slice(0, 2).map((t, j) => (
                    <div key={j} className="rounded-full" style={{ width: 4, height: 4, background: isSelected ? 'rgba(255,255,255,0.8)' : EVENT_COLORS[t] }}/>
                  ))}
                </div>
              )}
              {!hasActivity && <div style={{ height: 4 }}/>}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function GrowthEventCard({ event, onTap }: { event: GrowthEvent; onTap?: () => void }) {
  const color = EVENT_COLORS[event.type];
  const label = EVENT_LABELS[event.type];
  return (
    <button
      onClick={onTap}
      className="w-full text-left active:scale-[0.98] transition-transform"
    >
      <div className="flex gap-3 p-3 rounded-2xl" style={{ background: 'rgba(255,255,255,0.65)', border: '1px solid rgba(255,255,255,0.55)' }}>
        <div className="flex-shrink-0 mt-0.5">
          <div className="w-7 h-7 rounded-full flex items-center justify-center" style={{ background: `${color}18`, border: `1.5px solid ${color}40` }}>
            <div className="w-2 h-2 rounded-full" style={{ background: color }}/>
          </div>
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-0.5">
            <span style={{ fontSize: 9, fontWeight: 600, color, background: `${color}15`, borderRadius: 4, padding: '1px 5px' }}>{label}</span>
            {event.delta && <span style={{ fontSize: 10, fontWeight: 700, color: S.green }}>{event.delta}</span>}
          </div>
          <p style={{ fontSize: 13, fontWeight: 600, color: S.textPrimary, lineHeight: '18px' }}>{event.title}</p>
          <p style={{ fontSize: 11, color: S.textSecondary, marginTop: 1 }}>{event.sub}</p>
          {event.tag && (
            <div className="mt-1.5 inline-flex items-center px-2 py-0.5 rounded-full" style={{ background: `${color}12`, border: `1px solid ${color}25` }}>
              <span style={{ fontSize: 10, fontWeight: 500, color }}>{event.tag}</span>
            </div>
          )}
        </div>
      </div>
    </button>
  );
}

// ── Profile / My Page ─────────────────────────────────────────────────────────
function ProfilePage({ trialCount }: { trialCount: number }) {
  const { go } = useNav();
  const remaining = 3 - trialCount;
  const [selectedDate, setSelectedDate] = useState<number | null>(29);
  const [activeProfileTab, setActiveProfileTab] = useState<string>('职业资产');

  const selectedEvents = selectedDate ? GROWTH_EVENTS.filter(e => e.date === selectedDate) : [];

  const weekday = (d: number) => {
    const days = ['日', '一', '二', '三', '四', '五', '六'];
    return days[(6 + d - 1) % 7];
  };

  const profileTabs = [
    { label: '职业资产', action: () => setActiveProfileTab('职业资产') },
    { label: '成长足迹', action: () => { setActiveProfileTab('成长足迹'); go('growth-record'); } },
    { label: '我的简历', action: () => { setActiveProfileTab('我的简历'); go('resume-history'); } },
    { label: '历史分析', action: () => { setActiveProfileTab('历史分析'); go('analysis-history'); } },
    { label: '设置', action: () => { setActiveProfileTab('设置'); go('settings'); } },
  ];

  const careerAssets = [
    { n: '4', unit: '段', label: '工作经历', screen: 'work-exp' as NavScreen,
      icon: <svg width="17" height="17" viewBox="0 0 16.982 16.982" fill="none"><rect x="1.415" y="4.953" width="14.152" height="9.906" rx="0.99" stroke="white" strokeWidth="1.203"/><path d="M11.321 4.953V3.538a1.414 1.414 0 0 0-1.415-1.415H7.076a1.414 1.414 0 0 0-1.415 1.415v1.415" stroke="white" strokeWidth="1.203" strokeLinecap="round"/></svg> },
    { n: '6', unit: '个', label: '项目', screen: 'projects' as NavScreen,
      icon: <svg width="17" height="17" viewBox="0 0 16.982 16.982" fill="none"><path d="M2.123 2.123h4.953v4.953H2.123zM9.906 2.123h4.953v4.953H9.906zM2.123 9.906h4.953v4.953H2.123zM9.906 9.906h4.953v4.953H9.906z" stroke="white" strokeWidth="1.203" strokeLinecap="round" strokeLinejoin="round"/></svg> },
    { n: '12', unit: '项', label: '技能', screen: 'skills' as NavScreen,
      icon: <svg width="17" height="17" viewBox="0 0 16.982 16.982" fill="none"><path d="M8.491 1.415 6.36 6.368H1.062l4.15 3.184-2.123 5.308 5.302-3.538 5.303 3.538-2.123-5.308 4.15-3.184H10.623Z" stroke="white" strokeWidth="1.203" strokeLinejoin="round"/></svg> },
    { n: '3', unit: '个', label: '奖项', screen: 'awards' as NavScreen,
      icon: <svg width="17" height="17" viewBox="0 0 16.982 16.982" fill="none"><path d="M5.66 14.859h5.661M8.491 12.029v2.83M3.538 2.123h9.906l-1.415 4.953a3.538 3.538 0 0 1-7.076 0Z" stroke="white" strokeWidth="1.203" strokeLinecap="round" strokeLinejoin="round"/></svg> },
  ];

  return (
    <div className="pb-6">
      {/* ── Header: logo + settings ── */}
      <div style={{ height: 60, display: "flex", alignItems: "center", justifyContent: "space-between", paddingLeft: 24, paddingRight: 24, paddingTop: 16, paddingBottom: 12 }}>
        {/* Careerly logo clipped */}
        <div style={{ width: 109, height: 27, overflow: "hidden", position: "relative" }}>
          <div style={{ position: "absolute", left: -70.74, top: -46.21, width: 205, height: 137 }}>
            <img alt="careerly" src={imgCareerlyLogo} style={{ position: "absolute", width: "100%", height: "100%", objectFit: "cover", left: "12.23%", top: "-17.73%" }}/>
          </div>
        </div>
        {/* Settings glass button */}
        <button
          onClick={() => go("settings")}
          className="active:scale-90 transition-transform"
          style={{ width: 40, height: 40, borderRadius: 99, background: "rgba(255,255,255,0.45)", border: "1.188px solid rgba(255,255,255,0.4)", backdropFilter: "blur(16px)", WebkitBackdropFilter: "blur(16px)", boxShadow: "0px 4px 16px rgba(79,126,245,0.05)", display: "flex", alignItems: "center", justifyContent: "center" }}
        >
          <svg width="17" height="17" viewBox="0 0 16.982 16.982" fill="none">
            <circle cx="8.491" cy="8.491" r="2.123" stroke="#515151" strokeWidth="1.274"/>
            <path d="M13.727 10.614a1.415 1.415 0 0 0 .283 1.557l.036.036a1.415 1.415 0 1 1-2.001 2.001l-.037-.037a1.415 1.415 0 0 0-1.556-.282 1.415 1.415 0 0 0-.858 1.295v.106a1.415 1.415 0 0 1-2.83 0v-.056a1.415 1.415 0 0 0-.926-1.295 1.415 1.415 0 0 0-1.557.282l-.037.037a1.415 1.415 0 1 1-2-2l.036-.037a1.415 1.415 0 0 0 .282-1.557 1.415 1.415 0 0 0-1.295-.857H1.16a1.415 1.415 0 0 1 0-2.83h.055a1.415 1.415 0 0 0 1.295-.926 1.415 1.415 0 0 0-.282-1.557l-.037-.037a1.415 1.415 0 1 1 2.001-2l.037.036a1.415 1.415 0 0 0 1.556.282 1.415 1.415 0 0 0 .858-1.295V1.16a1.415 1.415 0 0 1 2.83 0v.055a1.415 1.415 0 0 0 .857 1.295 1.415 1.415 0 0 0 1.557-.282l.037-.037a1.415 1.415 0 0 1 2 2l-.036.037a1.415 1.415 0 0 0-.282 1.556 1.415 1.415 0 0 0 1.295.858h.106a1.415 1.415 0 0 1 0 2.83h-.056a1.415 1.415 0 0 0-1.295.857Z" stroke="#515151" strokeWidth="1.274"/>
          </svg>
        </button>
      </div>

      {/* ── Avatar centered ── */}
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", paddingTop: 12, paddingBottom: 12 }}>
        <div style={{ width: 96, height: 96, borderRadius: 99, backgroundImage: "linear-gradient(135deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)", boxShadow: "0px 8px 12px rgba(79,126,245,0.3)", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <span style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 28, color: "white", lineHeight: "33px" }}>A</span>
        </div>
      </div>

      {/* ── Info card ── */}
      <div style={{ paddingLeft: 24, paddingRight: 24, paddingTop: 8, paddingBottom: 8 }}>
        <div style={{ background: "rgba(255,255,255,0.68)", borderRadius: 24, border: "1.5px solid rgba(255,255,255,0.23)", boxShadow: "0px 12px 24px 0px rgba(155,177,201,0.25)", padding: 20, display: "flex", flexDirection: "column", gap: 16 }}>
          {/* Name row */}
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <div style={{ display: "flex", flexDirection: "column", gap: 2 }}>
              <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 18, color: "#181a20", lineHeight: "normal" }}>Alex</p>
              <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: "#6e717c", lineHeight: "normal" }}>@elmasekeri</p>
            </div>
            <button onClick={() => go("membership")} style={{ background: "#373b4d", borderRadius: 100, display: "flex", alignItems: "center", gap: 4, padding: "6px 12px" }}>
              <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                <path d="M2.5 10.5H9.5M5.78 1.633a.25.25 0 0 1 .44 0L7.695 4.435a.25.25 0 0 0 .378.088l2.138-1.773a.25.25 0 0 1 .402.228L9.196 8.132A.25.25 0 0 1 8.956 8.5H3.044a.25.25 0 0 1-.24-.368L1.387 2.978a.25.25 0 0 1 .402-.228L3.927 4.523a.25.25 0 0 0 .378-.088Z" stroke="#F2C94C" strokeLinecap="round" strokeWidth="2"/>
              </svg>
              <span style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 11, color: "white", whiteSpace: "nowrap" }}>V1会员</span>
            </button>
          </div>
          {/* Stats row */}
          <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", paddingTop: 4, paddingBottom: 4 }}>
            {([{ v: "4", l: "简历版本" }, { v: "22", l: "分析岗位" }, { v: "15", l: "分析次数" }] as const).map((stat, i) => (
              <div key={stat.l} style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: 4, minWidth: 0, position: "relative" }}>
                <p style={{ fontFamily: "'Inter:Extra Bold', sans-serif", fontWeight: 800, fontSize: 16, color: "#181a20", lineHeight: "normal" }}>{stat.v}</p>
                <p style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 11, color: "#6e717c", lineHeight: "normal" }}>{stat.l}</p>
                {i < 2 && <div style={{ position: "absolute", right: 0, top: "50%", transform: "translateY(-50%)", width: 1, height: 28, background: "rgba(18,18,18,0.082)" }}/>}
              </div>
            ))}
          </div>
          {/* CareerlyPro banner */}
          <button onClick={() => go("membership")} style={{ height: 53, borderRadius: 16, backgroundImage: "linear-gradient(170deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)", position: "relative", overflow: "hidden", width: "100%", textAlign: "left" }}>
            <div style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", display: "flex", alignItems: "center" }}>
              <span style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 20, color: "#f2c94c", lineHeight: "30px", marginRight: 8 }}>✦</span>
              <div style={{ display: "flex", flexDirection: "column", gap: 2 }}>
                <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 12, color: "white", lineHeight: "normal", whiteSpace: "nowrap" }}>Careerly Pro</p>
                <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 10, color: "#f4f5fc", lineHeight: "normal", whiteSpace: "nowrap" }}>
                  {remaining > 0 ? `免费体验剩余 ${remaining}/3 次 · 无限分析 AI 顾问` : "免费次数已用完，升级解锁无限功能"}
                </p>
              </div>
            </div>
          </button>
        </div>
      </div>

      {/* ── Filter tabs (scrollable) ── */}
      <div style={{ display: "flex", gap: 12, alignItems: "flex-start", overflowX: "auto", paddingLeft: 30, paddingRight: 20, paddingTop: 16, paddingBottom: 16, scrollbarWidth: "none" }}>
        {profileTabs.map(tab => (
          <button key={tab.label} onClick={tab.action}
            style={{ flexShrink: 0, borderRadius: 20, padding: "10px 16px", background: activeProfileTab === tab.label ? "#373b4d" : "white", border: activeProfileTab === tab.label ? "none" : "1px solid #eaeafa" }}>
            <span style={{ fontFamily: activeProfileTab === tab.label ? "'Roboto:SemiBold', sans-serif" : "'Roboto:Medium', sans-serif", fontWeight: activeProfileTab === tab.label ? 600 : 500, fontSize: 14, color: activeProfileTab === tab.label ? "white" : "rgba(30,31,34,0.6)", fontVariationSettings: '"wdth" 100', whiteSpace: "nowrap" }}>
              {tab.label}
            </span>
          </button>
        ))}
      </div>

      {/* ── Career assets gradient card ── */}
      <div style={{ paddingLeft: 20, paddingRight: 20, marginBottom: 20 }}>
        <div style={{ height: 156, borderRadius: 24, backgroundImage: "linear-gradient(156deg, rgb(79,126,245) 0%, rgb(167,123,230) 100%)", boxShadow: "0px 8px 24px 0px rgba(79,126,245,0.25)", position: "relative", overflow: "hidden" }}>
          {/* Header row */}
          <div style={{ position: "absolute", left: 0, right: 0, top: 0, height: 68, display: "flex", alignItems: "center", justifyContent: "space-between", paddingLeft: 16, paddingRight: 16, paddingTop: 16, paddingBottom: 12 }}>
            <div style={{ width: 40, height: 40, borderRadius: 12, background: "rgba(255,255,255,0.18)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <span style={{ fontSize: 18 }}>⭐</span>
            </div>
            <div style={{ flex: 1, paddingLeft: 12 }}>
              <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 13, color: "white", lineHeight: "19.5px" }}>职业资产</p>
              <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: "rgba(255,255,255,0.65)", lineHeight: "16.5px" }}>本月新增 1 项 · AI 能力 +8</p>
            </div>
            <button onClick={() => go("career-assets")} style={{ background: "rgba(255,255,255,0.15)", borderRadius: 22, display: "flex", alignItems: "center", gap: 4, padding: "5px 10px" }}>
              <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 11, color: "white", lineHeight: "16.5px" }}>查看全部</span>
              <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M4.5 9L7.5 6L4.5 3" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.1"/></svg>
            </button>
          </div>
          {/* Asset sub-cards */}
          <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", top: 68, display: "flex", gap: 8 }}>
            {careerAssets.map(item => (
              <button key={item.label} onClick={() => go(item.screen)}
                className="active:scale-[0.96] transition-transform"
                style={{ width: 75.5, height: 73, borderRadius: 14, background: "rgba(255,255,255,0.15)", padding: "11px 10px 10px", display: "flex", flexDirection: "column", alignItems: "flex-start", justifyContent: "center" }}>
                <div style={{ marginBottom: 2 }}>{item.icon}</div>
                <p style={{ fontFamily: "'Inter:Extra Bold', sans-serif", fontWeight: 800, fontSize: 17, color: "white", lineHeight: "22px" }}>
                  {item.n}<span style={{ fontFamily: "'Inter:Medium', sans-serif", fontWeight: 500, fontSize: 10, marginLeft: 2, color: "white" }}>{item.unit}</span>
                </p>
                <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 10, color: "rgba(255,255,255,0.7)", lineHeight: "15px" }}>{item.label}</p>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* ── 我的职业成长 (calendar) ── */}
      <div className="px-5 mb-4">
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
          <h2 style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 16, color: "#111827", lineHeight: "24px" }}>我的职业成长</h2>
          <button onClick={() => go("growth-record")} style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: "#4f7ef5", lineHeight: "18px" }}>查看全部 →</button>
        </div>
        <Card className="p-4">
          <GrowthCalendar selectedDate={selectedDate} onSelect={setSelectedDate}/>
          {selectedDate && selectedEvents.length > 0 && (
            <div className="mt-3 pt-3" style={{ borderTop: `1px solid ${S.divider}` }}>
              <p style={{ fontSize: 11, fontWeight: 600, color: S.textSecondary, marginBottom: 8 }}>
                8月{selectedDate}日 · 周{weekday(selectedDate)}
              </p>
              <div className="space-y-2">
                {selectedEvents.map((e, i) => (
                  <GrowthEventCard key={i} event={e} onTap={() => go("analysis-history")}/>
                ))}
              </div>
            </div>
          )}
        </Card>
      </div>

      {/* ── 我的简历 ── */}
      <div className="px-5 mb-3">
        <button className="w-full text-left active:scale-[0.98] transition-transform" onClick={() => go("resume-history")}>
          <div style={{ backdropFilter: "blur(24px)", WebkitBackdropFilter: "blur(24px)", background: "rgba(255,255,255,0.68)", border: "1.188px solid rgba(255,255,255,0.55)", borderRadius: 24, boxShadow: "0px 8px 32px 0px rgba(79,126,245,0.08)", padding: 16, display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ width: 40, height: 40, borderRadius: 12, background: "rgba(52,199,89,0.1)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <svg width="20" height="20" viewBox="0 0 19.989 19.989" fill="none">
                <path d="M11.663 1.666H4.997a1.666 1.666 0 0 0-1.664 1.664v13.328a1.666 1.666 0 0 0 1.664 1.664h9.995a1.666 1.666 0 0 0 1.664-1.664V6.662l-4.993-4.996Z" stroke="#34C759" strokeLinejoin="round" strokeWidth="1.416"/>
                <path d="M11.663 1.666v4.996h4.993" stroke="#34C759" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.416"/>
                <path d="M6.663 10.827h6.663M6.663 14.159h6.663" stroke="#34C759" strokeLinecap="round" strokeWidth="1.249"/>
              </svg>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: "#111827", lineHeight: "21px" }}>我的简历</p>
              <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: "#6b7280", lineHeight: "16.5px" }}>Resume V3 · 2026.08.27</p>
            </div>
            <div style={{ flexShrink: 0, display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 6 }}>
              <div style={{ background: "rgba(52,199,89,0.12)", borderRadius: 99, padding: "2px 8px" }}>
                <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 10, color: "#34c759", lineHeight: "15px" }}>最新版</span>
              </div>
              <svg width="14" height="14" viewBox="0 0 13.994 13.994" fill="none"><path d="M5.247 10.495L8.746 6.997L5.247 3.498" stroke="#6B7280" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.166"/></svg>
            </div>
          </div>
        </button>
      </div>

      {/* ── 历史分析 ── */}
      <div className="px-5 mb-3">
        <button className="w-full text-left active:scale-[0.98] transition-transform" onClick={() => go("analysis-history")}>
          <div style={{ backdropFilter: "blur(24px)", WebkitBackdropFilter: "blur(24px)", background: "rgba(255,255,255,0.68)", border: "1.188px solid rgba(255,255,255,0.55)", borderRadius: 24, boxShadow: "0px 8px 32px 0px rgba(79,126,245,0.08)", padding: 16, display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ width: 40, height: 40, borderRadius: 12, background: "rgba(79,126,245,0.09)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <svg width="20" height="20" viewBox="0 0 19.989 19.989" fill="none">
                <rect x="2.499" y="11.660" width="3.331" height="6.661" rx="0.833" fill="#4F7EF5"/>
                <rect x="8.329" y="7.496" width="3.331" height="10.825" rx="0.833" fill="#4F7EF5" fillOpacity="0.6"/>
                <rect x="14.159" y="3.332" width="3.331" height="14.989" rx="0.833" fill="#4F7EF5" fillOpacity="0.3"/>
              </svg>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: "#111827", lineHeight: "21px" }}>历史分析</p>
              <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: "#6b7280", lineHeight: "16.5px" }}>最近分析 2026.08.29 · 最高 86%</p>
            </div>
            <svg width="14" height="14" viewBox="0 0 13.994 13.994" fill="none" style={{ flexShrink: 0 }}><path d="M5.247 10.495L8.746 6.997L5.247 3.498" stroke="#6B7280" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.166"/></svg>
          </div>
        </button>
      </div>

      {/* ── 设置 ── */}
      <div className="px-5 mb-3">
        <button className="w-full text-left active:scale-[0.98] transition-transform" onClick={() => go("settings")}>
          <div style={{ backdropFilter: "blur(24px)", WebkitBackdropFilter: "blur(24px)", background: "rgba(255,255,255,0.68)", border: "1.188px solid rgba(255,255,255,0.55)", borderRadius: 24, boxShadow: "0px 8px 32px 0px rgba(79,126,245,0.08)", padding: 16, display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ width: 40, height: 40, borderRadius: 12, background: "rgba(107,114,128,0.08)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <svg width="20" height="20" viewBox="0 0 19.989 19.989" fill="none">
                <circle cx="9.994" cy="9.994" r="2.499" stroke="#6B7280" strokeWidth="1.499"/>
                <path d="M16.157 12.493a1.416 1.416 0 0 0 .283 1.557l.036.036a1.415 1.415 0 1 1-2 2l-.037-.036a1.416 1.416 0 0 0-1.557-.283 1.416 1.416 0 0 0-.857 1.295v.104a1.415 1.415 0 0 1-2.83 0v-.056a1.416 1.416 0 0 0-.926-1.295 1.416 1.416 0 0 0-1.557.283l-.036.037a1.415 1.415 0 1 1-2-2l.036-.037a1.416 1.416 0 0 0 .283-1.557 1.416 1.416 0 0 0-1.295-.857H3.64a1.415 1.415 0 0 1 0-2.83h.055a1.416 1.416 0 0 0 1.295-.926 1.416 1.416 0 0 0-.283-1.557l-.037-.036a1.415 1.415 0 1 1 2-2l.037.036A1.416 1.416 0 0 0 8.264 6.35a1.416 1.416 0 0 0 .857-1.295V4.95a1.415 1.415 0 0 1 2.83 0v.055a1.416 1.416 0 0 0 .857 1.295 1.416 1.416 0 0 0 1.557-.283l.037-.037a1.415 1.415 0 0 1 2 2l-.037.037a1.416 1.416 0 0 0-.283 1.557 1.416 1.416 0 0 0 1.295.857h.104a1.415 1.415 0 0 1 0 2.83h-.056a1.416 1.416 0 0 0-1.295.857Z" stroke="#6B7280" strokeWidth="1.499"/>
              </svg>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: "#111827", lineHeight: "21px" }}>设置</p>
              <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: "#6b7280", lineHeight: "16.5px" }}>账户 · 隐私 · 通知 · 关于</p>
            </div>
            <svg width="14" height="14" viewBox="0 0 13.994 13.994" fill="none" style={{ flexShrink: 0 }}><path d="M5.247 10.495L8.746 6.997L5.247 3.498" stroke="#6B7280" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.166"/></svg>
          </div>
        </button>
      </div>
    </div>
  );
}

// ─── Career Assets ─────────────────────────────────────────────────────────────
function CareerAssetsPage() {
  const { go, back } = useNav();
  const [expanded, setExpanded] = useState<string | null>(null);
  const toggle = (key: string) => setExpanded(p => p === key ? null : key);

  // Clock icon SVG
  const ClockIcon = ({ stroke }: { stroke: string }) => (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
      <path d="M6 2.99976V6L8.00016 7.00008M11.0004 6C11.0004 8.76164 8.76164 11.0004 6 11.0004C3.23836 11.0004 0.9996 8.76164 0.9996 6C0.9996 3.23836 3.23836 0.9996 6 0.9996C8.76164 0.9996 11.0004 3.23836 11.0004 6Z" stroke={stroke} strokeOpacity="0.6" strokeLinecap="round" strokeWidth="1.2"/>
    </svg>
  );

  // Frosted "查看全部" pill
  const ViewAllPill = ({ dark }: { dark?: boolean }) => (
    <div style={{ background: 'rgba(255,255,255,0.62)', border: '1px solid white', borderRadius: 12, padding: '6px 12px' }}>
      <span style={{ fontFamily: "'Roboto:SemiBold', sans-serif", fontWeight: 600, fontSize: 12, color: dark ? '#171827' : 'white', fontVariationSettings: '"wdth" 100' }}>查看全部</span>
    </div>
  );

  // Arrow circle button with icon
  const ArrowCircle = ({ iconPath, iconStroke }: { iconPath: string; iconStroke: string }) => (
    <div style={{ width: 36, height: 36, borderRadius: 18, background: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
      <svg width="18" height="18" viewBox="0 0 21.994 21.994" fill="none">
        <path d={iconPath} stroke={iconStroke} strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.65"/>
      </svg>
    </div>
  );

  const svgWork = "M17.4119 6.41492H4.58208C3.06371 6.41492 1.83283 7.6458 1.83283 9.16417V16.4955C1.83283 18.0139 3.06371 19.2448 4.58208 19.2448H17.4119C18.9303 19.2448 20.1612 18.0139 20.1612 16.4955V9.16417C20.1612 7.6458 18.9303 6.41492 17.4119 6.41492Z";
  const svgProjects = "M2.12275 2.12275H7.07583V7.07583H2.12275V2.12275ZM9.90617 2.12275H14.8592V7.07583H9.90617V2.12275ZM2.12275 9.90617H7.07583V14.8592H2.12275V9.90617ZM9.90617 9.90617H14.8592V14.8592H9.90617V9.90617Z";
  const svgSkills = "M10.997 1.83283L8.70596 8.24775H2.29104L7.33133 12.3716L5.04029 19.2447L10.997 14.6627L16.9537 19.2447L14.6627 12.3716L19.703 8.24775H13.288L10.997 1.83283Z";
  const svgAwards = "M7.33133 19.2447H14.6627M10.997 15.5791V19.2447M4.58208 2.74925H17.4119L15.5791 9.16417C15.5791 10.3794 15.0963 11.5449 14.237 12.4042C13.3777 13.2635 12.2122 13.7462 10.997 13.7462C9.78176 13.7462 8.61629 13.2635 7.75698 12.4042C6.89767 11.5449 6.41492 10.3794 6.41492 9.16417L4.58208 2.74925Z";

  type AssetDef = {
    key: string;
    label: string;
    countLabel: string;
    screen: NavScreen;
    cardStyle: React.CSSProperties;
    titleColor: string;
    countColor: string;
    clockColor: string;
    dateColor: string;
    iconPath: string;
    iconStroke: string;
    titleFont: string;
    viewAllDark?: boolean;
  };

  const ASSETS: AssetDef[] = [
    {
      key: 'work',
      label: '工作经历',
      countLabel: `${WORK_EXP.length} 段职业经历`,
      screen: 'work-exp',
      cardStyle: { background: '#373b4d', borderRadius: 24, boxShadow: '0px 8px 16px 0px rgba(0,0,0,0.06)', overflow: 'hidden' },
      titleColor: 'white',
      countColor: '#a2d84c',
      clockColor: 'white',
      dateColor: 'rgba(255,255,255,0.68)',
      iconPath: svgWork,
      iconStroke: '#111827',
      titleFont: "'Noto Sans SC:Bold', sans-serif",
    },
    {
      key: 'projects',
      label: '项目经历',
      countLabel: `${PROJECTS_DATA.length} 个项目经历`,
      screen: 'projects',
      cardStyle: { background: '#f1f2f6', borderRadius: 24, overflow: 'hidden' },
      titleColor: '#171827',
      countColor: '#171827',
      clockColor: '#1e1f22',
      dateColor: 'rgba(30,31,34,0.6)',
      iconPath: svgProjects,
      iconStroke: '#201E22',
      titleFont: "'Noto Sans SC:Bold', sans-serif",
      viewAllDark: true,
    },
    {
      key: 'skills',
      label: '专业技能',
      countLabel: '12项目技能',
      screen: 'skills',
      cardStyle: { background: 'linear-gradient(162.6deg, #4f7ef5 0%, #a77be6 100%)', borderRadius: 24, boxShadow: '0px 8px 24px 0px rgba(79,126,245,0.25)', overflow: 'hidden' },
      titleColor: 'white',
      countColor: '#1e1f22',
      clockColor: '#1e1f22',
      dateColor: 'rgba(30,31,34,0.6)',
      iconPath: svgSkills,
      iconStroke: '#7B5CCC',
      titleFont: "'Noto Sans SC:Bold', sans-serif",
    },
    {
      key: 'awards',
      label: '荣誉成果',
      countLabel: `${AWARDS.length} 项荣誉记录`,
      screen: 'awards',
      cardStyle: { background: '#c3aff1', borderRadius: 24, overflow: 'hidden' },
      titleColor: 'white',
      countColor: '#1e1f22',
      clockColor: '#1e1f22',
      dateColor: 'rgba(30,31,34,0.6)',
      iconPath: svgAwards,
      iconStroke: '#C44B8A',
      titleFont: "'Noto Sans SC:Medium', sans-serif",
    },
  ];

  // Frosted glass panel for expanded content
  const frostPanel = {
    backdropFilter: 'blur(20px)',
    WebkitBackdropFilter: 'blur(20px)',
    background: 'rgba(255,255,255,0.72)',
    border: '1px solid rgba(255,255,255,0.8)',
    borderRadius: '0 0 24px 24px',
    padding: '14px 20px 20px',
  };

  // Skill bar row for 职业能力画像
  const SkillBar = ({ label, score, delta, width }: { label: string; score: number; delta: number; width: string }) => (
    <div className="flex gap-2 items-center h-[25px] pt-[8px] w-full">
      <div style={{ width: 72, flexShrink: 0 }}>
        <span style={{ fontFamily: "'Inter:Regular', 'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#6b7280', lineHeight: '16.5px', whiteSpace: 'nowrap' }}>{label}</span>
      </div>
      <div className="flex-1 min-w-px h-[5px] rounded-full overflow-hidden" style={{ background: 'rgba(79,126,245,0.1)' }}>
        <div style={{ width, height: '100%', borderRadius: 9999, backgroundImage: 'linear-gradient(178deg, #cadb8f 0%, #a2d84c 100%)' }}/>
      </div>
      <div style={{ width: 22, textAlign: 'right', flexShrink: 0 }}>
        <span style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 11, color: '#111827', lineHeight: '16.5px' }}>{score}</span>
      </div>
      <div style={{ width: 22, flexShrink: 0 }}>
        <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 10, color: '#34c759', lineHeight: '15px' }}>+{delta}</span>
      </div>
    </div>
  );

  return (
    <div className="flex flex-col h-full">
      {/* Header: centered title + glass back button */}
      <div className="relative flex items-center justify-center px-5 pt-4 pb-2 flex-shrink-0" style={{ height: 56 }}>
        <button
          onClick={back}
          className="absolute left-5 active:opacity-70 transition-opacity"
          style={{ width: 44, height: 44, borderRadius: 296, display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'rgba(255,255,255,0.7)', backdropFilter: 'blur(8px)', border: '1px solid rgba(220,220,240,0.5)' }}
        >
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none"><path d="M15 18L9 12L15 6" stroke="#0088ff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </button>
        <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 22, color: '#1e1f22' }}>职业资产</p>
      </div>

      {/* Subtitle */}
      <p className="px-6 pb-3 text-[13px]" style={{ color: '#6b7280' }}>
        <span style={{ fontFamily: "'Roboto:Regular', sans-serif", fontVariationSettings: '"wdth" 100' }}>{" AI "}</span>
        <span style={{ fontFamily: "'Noto Sans SC:Regular', sans-serif" }}>对你的简历和职业经历的持续记录与分析。</span>
      </p>

      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-3">
        {ASSETS.map(a => {
          const open = expanded === a.key;
          return (
            <div key={a.key} style={{ ...a.cardStyle, borderRadius: 24, overflow: 'hidden' }}>
              {/* Card top section — clickable to expand */}
              <button
                className="w-full text-left active:opacity-80 transition-opacity"
                style={{ padding: 20, display: 'flex', flexDirection: 'column', gap: 20 }}
                onClick={() => toggle(a.key)}
              >
                {/* Top row: title + count + arrow circle */}
                <div className="flex items-start justify-between w-full">
                  <p style={{ fontFamily: a.titleFont, fontWeight: a.key === 'awards' ? 500 : 700, fontSize: 20, color: a.titleColor, lineHeight: 1.3, width: 200 }}>{a.label}</p>
                  <div className="flex items-center gap-2.5 flex-shrink-0">
                    <span style={{ fontFamily: "'Roboto:SemiBold', 'Noto Sans SC:Bold', sans-serif", fontWeight: 600, fontSize: 12, color: a.countColor, fontVariationSettings: '"wdth" 100', whiteSpace: 'nowrap' }}>{a.countLabel}</span>
                    <ArrowCircle iconPath={a.iconPath} iconStroke={a.iconStroke}/>
                  </div>
                </div>
                {/* Bottom row: date + view all */}
                <div className="flex items-center justify-between w-full">
                  <div className="flex items-center gap-1.5">
                    <ClockIcon stroke={a.clockColor}/>
                    <span style={{ fontFamily: "'Roboto:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: a.dateColor, fontVariationSettings: '"wdth" 100', whiteSpace: 'nowrap' }}>2021/6/8 - 2026/9/9</span>
                  </div>
                  <ViewAllPill dark={a.viewAllDark}/>
                </div>
              </button>

              {/* Expanded detail — frosted white glass */}
              {open && (
                <div style={frostPanel}>
                  {a.key === 'work' && (
                    <div className="space-y-3">
                      {WORK_EXP.map((w, i) => (
                        <button key={w.id} className="w-full text-left active:opacity-75" onClick={e => { e.stopPropagation(); go('work-detail', { index: i }); }}>
                          <div className="flex gap-3">
                            <div className="flex flex-col items-center flex-shrink-0 pt-1">
                              <div className="w-2 h-2 rounded-full" style={{ background: S.primaryBlue }}/>
                              {i < WORK_EXP.length - 1 && <div className="w-px flex-1 mt-1" style={{ minHeight: 36, background: 'rgba(79,126,245,0.2)' }}/>}
                            </div>
                            <div className="flex-1 pb-1">
                              <p className="text-[10px] mb-0.5" style={{ color: S.textSecondary, fontFamily: "'Roboto:Regular', sans-serif" }}>{w.period}</p>
                              <p className="text-[13px] font-bold" style={{ color: S.textPrimary }}>{w.title}</p>
                              <p className="text-[12px]" style={{ color: S.textSecondary }}>{w.company}</p>
                            </div>
                          </div>
                        </button>
                      ))}
                    </div>
                  )}
                  {a.key === 'projects' && (
                    <div className="space-y-2">
                      {PROJECTS_DATA.map((p, i) => (
                        <button key={p.id} className="w-full text-left active:opacity-75" onClick={e => { e.stopPropagation(); go('project-detail', { index: i }); }}>
                          <div className="flex items-center justify-between py-1.5">
                            <p className="text-[13px] font-bold truncate" style={{ color: S.textPrimary, maxWidth: '75%' }}>{p.name}</p>
                            <span className="text-[11px]" style={{ color: S.textSecondary }}>{p.year}</span>
                          </div>
                        </button>
                      ))}
                    </div>
                  )}
                  {a.key === 'skills' && (
                    <div className="flex flex-wrap gap-2">
                      {SKILL_CATS.flatMap(cat => cat.skills).map(s => (
                        <span key={s} className="text-[11px] font-semibold px-2.5 py-1 rounded-xl" style={{ background: 'rgba(79,126,245,0.08)', color: S.primaryBlue }}>{s}</span>
                      ))}
                    </div>
                  )}
                  {a.key === 'awards' && (
                    <div className="space-y-2.5">
                      {AWARDS.map((aw, i) => (
                        <div key={i} className="flex items-start gap-2.5">
                          <div className="w-1.5 h-1.5 rounded-full mt-1.5 flex-shrink-0" style={{ background: '#C44B8A' }}/>
                          <div>
                            <p className="text-[13px] font-bold" style={{ color: S.textPrimary }}>{aw.name}</p>
                            <p className="text-[11px]" style={{ color: '#C44B8A' }}>{aw.year} · {aw.org}</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                  <button onClick={e => { e.stopPropagation(); go(a.screen); }} className="mt-3 flex items-center gap-1 active:opacity-70" style={{ color: S.primaryBlue }}>
                    <span style={{ fontFamily: "'Roboto:SemiBold', sans-serif", fontSize: 12, fontWeight: 600 }}>查看全部</span>
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M5 12H19M19 12L12 5M19 12L12 19" stroke={S.primaryBlue} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
                  </button>
                </div>
              )}
            </div>
          );
        })}

        {/* 职业能力画像 card — light bg with skill bars */}
        <div style={{ background: '#f1f2f6', borderRadius: 24, overflow: 'hidden' }}>
          <div style={{ paddingTop: 28, paddingBottom: 20, paddingLeft: 20, paddingRight: 20, display: 'flex', flexDirection: 'column', gap: 16 }}>
            {/* Top row */}
            <div className="flex items-start justify-between w-full">
              <p style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 20, color: '#b4c481', lineHeight: 1.3, width: 200 }}>职业能力画像</p>
              <div className="flex items-center gap-2.5 flex-shrink-0">
                <span style={{ fontFamily: "'Roboto:SemiBold', 'Noto Sans SC:Bold', sans-serif", fontWeight: 600, fontSize: 12, color: '#a2d84c', fontVariationSettings: '"wdth" 100' }}>点击查看</span>
                <div style={{ width: 36, height: 36, borderRadius: 18, background: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <svg width="18" height="18" viewBox="0 0 21.994 21.994" fill="none">
                    <path d="M1.83283 5.4985C1.83283 5.0124 2.02593 4.54621 2.36966 4.20249C2.71338 3.85877 3.17957 3.66567 3.66567 3.66567H8.24775L10.0806 5.4985H18.3283C18.8144 5.4985 19.2806 5.6916 19.6243 6.03532C19.9681 6.37905 20.1612 6.84524 20.1612 7.33133V16.4955C20.1612 16.9816 19.9681 17.4478 19.6243 17.7915C19.2806 18.1352 18.8144 18.3283 18.3283 18.3283H3.66567C3.17957 18.3283 2.71338 18.1352 2.36966 17.7915C2.02593 17.4478 1.83283 16.9816 1.83283 16.4955V5.4985Z" stroke="#111827" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.65"/>
                  </svg>
                </div>
              </div>
            </div>
            {/* Progress bar */}
            <div style={{ background: '#e1e2e8', borderRadius: 12, height: 24, overflow: 'hidden' }}>
              <div style={{ background: '#cadb8f', height: '100%', width: '62%', display: 'flex', alignItems: 'center', paddingLeft: 12 }}>
                <span style={{ fontFamily: "'Roboto:SemiBold', 'Noto Sans SC:Bold', sans-serif", fontSize: 11, fontWeight: 600, color: 'rgba(255,255,255,0.9)', fontVariationSettings: '"wdth" 100', opacity: 0.9 }}>你的资产正在成就你的能力</span>
              </div>
            </div>
            {/* Skill bars */}
            <div style={{ width: '100%' }}>
              <SkillBar label="产品规划" score={85} delta={5} width="91%"/>
              <SkillBar label="AI 应用能力" score={76} delta={8} width="76%"/>
              <SkillBar label="用户研究" score={78} delta={3} width="78%"/>
            </div>
            {/* Bottom row */}
            <div className="flex items-center justify-between w-full">
              <div className="flex items-center gap-1.5">
                <ClockIcon stroke="#1e1f22"/>
                <span style={{ fontFamily: "'Inter:Regular', 'Noto Sans SC:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#6b7280', lineHeight: '16.5px' }}>5 个维度 · 综合上升中</span>
              </div>
              <button onClick={() => go('capability')} style={{ background: '#373b4d', borderRadius: 12, border: '1px solid white', padding: '6px 12px' }}>
                <span style={{ fontFamily: "'Roboto:SemiBold', 'Noto Sans SC:Bold', sans-serif", fontWeight: 600, fontSize: 12, color: 'white', fontVariationSettings: '"wdth" 100' }}>查看全部</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function WorkExperiencePage() {
  const { go, back } = useNav();
  return (
    <div className="flex flex-col h-full">
      <TopBar title="工作经历" onBack={back} right={<span className="text-[13px]" style={{ color: S.textSecondary }}>{WORK_EXP.length} 段</span>}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        {WORK_EXP.map((w, i) => (
          <button key={w.id} className="w-full text-left stagger-item" onClick={() => go('work-detail', { index: i })}>
            <Card className="p-4">
              <div className="flex items-start gap-3">
                <div className="flex flex-col items-center flex-shrink-0 pt-1">
                  <div className="w-3 h-3 rounded-full border-2" style={{ borderColor: S.primaryBlue, background: 'white' }}/>
                  {i < WORK_EXP.length - 1 && <div className="w-0.5 mt-2" style={{ height: 60, background: 'rgba(79,126,245,0.2)' }}/>}
                </div>
                <div className="flex-1">
                  <p className="text-[10px] font-medium mb-1" style={{ color: S.textSecondary }}>{w.period}</p>
                  <p className="text-[15px] font-bold" style={{ color: S.textPrimary }}>{w.title}</p>
                  <p className="text-[13px]" style={{ color: S.textSecondary }}>{w.company}</p>
                  <div className="flex flex-wrap gap-1.5 mt-2">
                    {w.skills.map(s => (
                      <span key={s.name} className="text-[10px] font-semibold px-2 py-0.5 rounded-full" style={{ background: 'rgba(52,199,89,0.12)', color: S.green }}>
                        {s.name} +{s.delta}
                      </span>
                    ))}
                  </div>
                </div>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 18L15 12L9 6" stroke={S.textSecondary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </div>
            </Card>
          </button>
        ))}
      </div>
    </div>
  );
}

function WorkDetailPage() {
  const { back, params } = useNav();
  const w = WORK_EXP[(params.index as number) ?? 0];
  return (
    <div className="flex flex-col h-full">
      <TopBar title="工作经历" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        <div className="rounded-3xl p-5 relative overflow-hidden" style={{ background: S.primary }}>
          <div className="absolute -top-8 -right-8 w-32 h-32 rounded-full" style={{ background: 'rgba(255,255,255,0.08)' }}/>
          <div className="relative">
            <p className="text-white/60 text-[11px] uppercase tracking-widest mb-1">{w.period}</p>
            <h2 className="text-white font-bold text-[22px]">{w.title}</h2>
            <p className="text-white/75 text-[14px] mt-0.5">{w.company}</p>
          </div>
        </div>
        <Card className="p-5">
          <h3 className="text-[14px] font-bold mb-2" style={{ color: S.textPrimary }}>工作内容</h3>
          <p className="text-[13px] leading-relaxed" style={{ color: S.textSecondary }}>{w.desc}</p>
        </Card>
        <Card className="p-5">
          <h3 className="text-[14px] font-bold mb-3" style={{ color: S.textPrimary }}>带来的能力提升</h3>
          {w.skills.map((s, i) => (
            <div key={s.name}>
              <div className="flex items-center justify-between py-3">
                <span className="text-[14px]" style={{ color: S.textPrimary }}>{s.name}</span>
                <span className="text-[13px] font-bold px-2.5 py-0.5 rounded-full" style={{ background: 'rgba(52,199,89,0.12)', color: S.green }}>+{s.delta}</span>
              </div>
              {i < w.skills.length - 1 && <Divider/>}
            </div>
          ))}
        </Card>
        {w.projects.length > 0 && (
          <Card className="p-5">
            <h3 className="text-[14px] font-bold mb-3" style={{ color: S.textPrimary }}>相关项目</h3>
            {w.projects.map((p, i) => (
              <div key={p}>
                <div className="flex items-center gap-2 py-2.5">
                  <div className="w-2 h-2 rounded-full" style={{ background: S.primaryBlue }}/>
                  <span className="text-[14px]" style={{ color: S.textPrimary }}>{p}</span>
                </div>
                {i < w.projects.length - 1 && <Divider/>}
              </div>
            ))}
          </Card>
        )}
      </div>
    </div>
  );
}

function ProjectExperiencePage() {
  const { go, back } = useNav();
  return (
    <div className="flex flex-col h-full">
      <TopBar title="项目经历" onBack={back} right={<span className="text-[13px]" style={{ color: S.textSecondary }}>{PROJECTS_DATA.length} 个</span>}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-3">
        {PROJECTS_DATA.map((p, i) => (
          <button key={p.id} className="w-full text-left stagger-item" onClick={() => go('project-detail', { index: i })}
            onPointerDown={e => (e.currentTarget.style.transform = 'scale(0.98)')}
            onPointerUp={e => (e.currentTarget.style.transform = 'scale(1)')}
            onPointerLeave={e => (e.currentTarget.style.transform = 'scale(1)')}
            style={{ transition: 'transform 120ms cubic-bezier(0.25,0.46,0.45,0.94)' }}>
            <Card className="p-4">
              <div className="flex items-start justify-between mb-2">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full" style={{ background: 'rgba(79,126,245,0.10)', color: S.primaryBlue }}>{p.type}</span>
                    <span className="text-[11px]" style={{ color: S.textSecondary }}>{p.year}</span>
                  </div>
                  <p className="text-[16px] font-bold" style={{ color: S.textPrimary }}>{p.name}</p>
                  <p className="text-[12px]" style={{ color: S.textSecondary }}>{p.role}</p>
                </div>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 18L15 12L9 6" stroke={S.textSecondary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </div>
              <div className="flex flex-wrap gap-1.5 mt-2">
                {p.skills.map(s => <span key={s} className="text-[10px] font-medium px-2 py-0.5 rounded-full" style={{ background: 'rgba(167,123,230,0.10)', color: S.primaryPurple }}>{s}</span>)}
              </div>
              {p.jobImpact.length > 0 && (
                <div className="mt-2 flex items-center gap-1">
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M23 6L13.5 15.5L8.5 10.5L1 18" stroke={S.green} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
                  <span className="text-[11px] font-semibold" style={{ color: S.green }}>{p.jobImpact[0].job} +{p.jobImpact[0].delta}%</span>
                </div>
              )}
            </Card>
          </button>
        ))}
      </div>
    </div>
  );
}

function ProjectDetailPage() {
  const { back, params } = useNav();
  const p = PROJECTS_DATA[(params.index as number) ?? 0];
  return (
    <div className="flex flex-col h-full">
      <TopBar title="项目经历" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        <div className="rounded-3xl p-5 relative overflow-hidden" style={{ background: S.primary }}>
          <div className="absolute -top-8 -right-8 w-32 h-32 rounded-full" style={{ background: 'rgba(255,255,255,0.08)' }}/>
          <div className="relative">
            <div className="flex items-center gap-2 mb-2">
              <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full" style={{ background: 'rgba(255,255,255,0.25)', color: 'white' }}>{p.type}</span>
              <span className="text-white/60 text-[11px]">{p.year}</span>
            </div>
            <h2 className="text-white font-bold text-[22px]">{p.name}</h2>
            <p className="text-white/70 text-[13px] mt-0.5">{p.role}</p>
          </div>
        </div>
        <Card className="p-5">
          <h3 className="text-[14px] font-bold mb-2" style={{ color: S.textPrimary }}>项目背景</h3>
          <p className="text-[13px] leading-relaxed" style={{ color: S.textSecondary }}>{p.desc}</p>
        </Card>
        <Card className="p-5">
          <h3 className="text-[14px] font-bold mb-2" style={{ color: S.textPrimary }}>项目成果</h3>
          <p className="text-[13px] leading-relaxed" style={{ color: S.textSecondary }}>{p.outcome}</p>
        </Card>
        <Card className="p-5">
          <h3 className="text-[14px] font-bold mb-3" style={{ color: S.textPrimary }}>相关能力</h3>
          {p.skills.map((s, i) => (
            <div key={s}>
              <div className="flex items-center gap-2 py-2.5">
                <div className="w-2 h-2 rounded-full" style={{ background: S.primaryPurple }}/>
                <span className="text-[14px]" style={{ color: S.textPrimary }}>{s}</span>
              </div>
              {i < p.skills.length - 1 && <Divider/>}
            </div>
          ))}
        </Card>
        {p.jobImpact.length > 0 && (
          <Card className="p-4" style={{ background: 'rgba(52,199,89,0.08)', border: '1px solid rgba(52,199,89,0.20)' }}>
            <p className="text-[12px] font-semibold mb-2" style={{ color: '#15803D' }}>影响的岗位匹配</p>
            {p.jobImpact.map(ji => (
              <div key={ji.job} className="flex items-center justify-between">
                <span className="text-[14px] font-semibold" style={{ color: S.textPrimary }}>{ji.job}</span>
                <span className="text-[14px] font-bold" style={{ color: S.green }}>↑ +{ji.delta}%</span>
              </div>
            ))}
          </Card>
        )}
      </div>
    </div>
  );
}

function SkillsPage() {
  const { back } = useNav();
  return (
    <div className="flex flex-col h-full">
      <TopBar title="技能" onBack={back} right={<span className="text-[13px]" style={{ color: S.textSecondary }}>12 项</span>}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        {SKILL_CATS.map(cat => (
          <Card key={cat.cat} className="p-5 stagger-item">
            <h3 className="text-[14px] font-bold mb-3" style={{ color: S.textPrimary }}>{cat.cat}</h3>
            <div className="flex flex-wrap gap-2">
              {cat.skills.map(s => (
                <span key={s} className="text-[13px] font-medium px-3 py-1.5 rounded-xl" style={{ background: 'rgba(79,126,245,0.08)', color: S.primaryBlue }}>{s}</span>
              ))}
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

function AwardsPage() {
  const { back } = useNav();
  return (
    <div className="flex flex-col h-full">
      <TopBar title="奖项" onBack={back} right={<span className="text-[13px]" style={{ color: S.textSecondary }}>{AWARDS.length} 项</span>}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-3">
        {AWARDS.map((a, i) => (
          <Card key={i} className="p-5 stagger-item">
            <div className="flex items-start gap-3">
              <div className="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0 text-[22px]" style={{ background: 'rgba(255,149,0,0.10)' }}>🏆</div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-0.5">
                  <p className="text-[15px] font-bold" style={{ color: S.textPrimary }}>{a.name}</p>
                  <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full" style={{ background: 'rgba(255,149,0,0.12)', color: S.orange }}>{a.year}</span>
                </div>
                <p className="text-[12px] mb-1" style={{ color: S.textSecondary }}>{a.org}</p>
                <p className="text-[12px] leading-relaxed" style={{ color: S.textSecondary }}>{a.desc}</p>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

// ─── Capability ───────────────────────────────────────────────────────────────
function CapabilityPage() {
  const { go, back } = useNav();
  return (
    <div className="flex flex-col h-full">
      <TopBar title="我的能力" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        <Card className="p-5">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-[15px] font-bold" style={{ color: S.textPrimary }}>能力雷达图</h3>
            <div className="flex items-center gap-3 text-[10px]" style={{ color: S.textSecondary }}>
              <span className="flex items-center gap-1"><span className="inline-block w-3 h-0.5 rounded-full" style={{ background: '#4F7EF5' }}/>当前</span>
              <span className="flex items-center gap-1"><span className="inline-block w-3 h-0.5 rounded-full" style={{ background: 'rgba(167,123,230,0.45)' }}/>上次</span>
            </div>
          </div>
          <div className="flex justify-center"><RadarChart skills={SKILLS_DATA}/></div>
        </Card>
        <Card className="p-5">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-[15px] font-bold" style={{ color: S.textPrimary }}>能力详情</h3>
            <button onClick={() => go('cap-change')} className="text-[12px] font-semibold" style={{ color: S.primaryBlue }}>查看变化 →</button>
          </div>
          {SKILLS_DATA.map((s, i) => (
            <div key={s.name} className={i > 0 ? 'mt-4' : ''}>
              <div className="flex items-center justify-between mb-2">
                <span className="text-[13px] font-semibold" style={{ color: S.textPrimary }}>{s.name}</span>
                <div className="flex items-center gap-2">
                  <span className="text-[15px] font-bold" style={{ color: S.textPrimary }}>{s.score}</span>
                  {s.delta > 0 && <span className="text-[11px] font-bold px-1.5 py-0.5 rounded-full" style={{ background: 'rgba(52,199,89,0.12)', color: S.green }}>+{s.delta}</span>}
                  {s.delta === 0 && <span className="text-[11px] px-1.5 py-0.5 rounded-full" style={{ background: 'rgba(107,114,128,0.08)', color: S.textSecondary }}>—</span>}
                </div>
              </div>
              <div className="relative h-2 rounded-full overflow-hidden" style={{ background: 'rgba(229,231,235,0.8)' }}>
                <div className="absolute h-full rounded-full bar-grow" style={{ width: `${s.prev}%`, background: 'rgba(167,123,230,0.25)', animationDelay: `${i * 80 + 100}ms` }}/>
                <div className="absolute h-full rounded-full bar-grow" style={{ width: `${s.score}%`, background: S.primary, animationDelay: `${i * 80 + 200}ms` }}/>
              </div>
              <p className="text-[10px] mt-1" style={{ color: S.textSecondary }}>上次 {s.prev} → 现在 {s.score}</p>
            </div>
          ))}
        </Card>
      </div>
    </div>
  );
}

function CapabilityChangePage() {
  const { back } = useNav();
  return (
    <div className="flex flex-col h-full">
      <TopBar title="能力变化" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        <p className="text-[13px]" style={{ color: S.textSecondary }}>你的职业能力正在持续成长。</p>
        {SKILLS_DATA.map((s, i) => (
          <Card key={i} className="p-5">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-[15px] font-bold" style={{ color: S.textPrimary }}>{s.name}</h3>
              {s.delta > 0
                ? <span className="text-[13px] font-bold px-2.5 py-1 rounded-full" style={{ background: 'rgba(52,199,89,0.12)', color: S.green }}>↑ +{s.delta}</span>
                : <span className="text-[13px] px-2.5 py-1 rounded-full" style={{ background: 'rgba(107,114,128,0.08)', color: S.textSecondary }}>—</span>}
            </div>
            <div className="flex gap-3">
              {[{ date: '2026.06', score: Math.max(s.prev - 4, 50) }, { date: '2026.07', score: s.prev }, { date: '2026.08', score: s.score }].map((h, j, arr) => (
                <div key={h.date} className="flex-1 rounded-xl py-3 text-center" style={{ background: j === arr.length - 1 ? 'rgba(79,126,245,0.10)' : 'rgba(229,231,235,0.4)' }}>
                  <p className="text-[16px] font-bold" style={{ color: j === arr.length - 1 ? S.primaryBlue : S.textPrimary }}>{h.score}</p>
                  <p className="text-[9px] mt-0.5" style={{ color: S.textSecondary }}>{h.date}</p>
                </div>
              ))}
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

// Extended timeline data with time labels
const GROWTH_TIMELINE = [
  {
    date: '2026.08', time: '08月', event: '新增 AI Agent 项目',
    desc: '完成 AI 招聘助手 MVP 上线，主导产品规划与落地。',
    tag: 'AI 能力 +8', effect: 'AI产品经理 78%→86%',
    type: 'project' as GrowthEventType,
  },
  {
    date: '2026.06', time: '06月', event: '完成用户研究认证',
    desc: '通过专项培训，系统强化用户访谈与数据分析能力。',
    tag: '用户研究 +3', effect: '产品经理 76%→79%',
    type: 'capability' as GrowthEventType,
  },
  {
    date: '2026.05', time: '05月', event: '更新简历 V2',
    desc: '补充用户研究案例，完善职业经历描述与项目成果。',
    tag: '产品规划 +5', effect: '多个岗位提升',
    type: 'resume' as GrowthEventType,
  },
  {
    date: '2026.03', time: '03月', event: '完成职业分析 #2',
    desc: '与 3 个目标岗位对比分析，最高匹配度 78%。',
    tag: '分析完成', effect: 'AI产品经理 匹配 78%',
    type: 'analysis' as GrowthEventType,
  },
  {
    date: '2026.01', time: '01月', event: '创建第一份简历',
    desc: '基于职业经历整理并创建 Resume V1，启动职业成长档案。',
    tag: '简历创建', effect: '开始职业档案',
    type: 'resume' as GrowthEventType,
  },
];

function GrowthRecordPage() {
  const { back } = useNav();

  // Design-accurate colors from import
  const dotColor: Record<GrowthEventType, string> = {
    project:    '#6c7ee1',
    capability: '#ff9c6e',
    resume:     '#b08ae0',
    analysis:   '#4cc87a',
  };
  const cardBg: Record<GrowthEventType, string> = {
    project:    '#eef1fe',
    capability: '#fff2ec',
    resume:     '#f3effe',
    analysis:   'rgba(202,219,143,0.35)',
  };
  const lineColor: Record<GrowthEventType, string> = {
    project:    'rgb(197,200,224)',
    capability: 'rgb(217,191,176)',
    resume:     'rgb(204,192,224)',
    analysis:   'rgb(176,217,192)',
  };
  const typeLabel: Record<GrowthEventType, string> = {
    project: '项目', capability: '能力', resume: '简历', analysis: '分析',
  };

  return (
    <div className="flex flex-col h-full" style={{ backgroundImage: 'linear-gradient(142.84deg, rgb(225,225,250) 18.9%, rgb(245,240,250) 46.9%, rgb(240,244,253) 81.1%)' }}>
      {/* Header */}
      <div className="flex-shrink-0 px-6 pt-4 pb-0">
        <div className="flex items-center gap-3" style={{ paddingBottom: 6 }}>
          <button
            onClick={back}
            className="flex items-center justify-center active:scale-90 transition-transform flex-shrink-0"
            style={{ width: 32, height: 32, borderRadius: 12, background: 'white', boxShadow: '0px 2px 4px rgba(0,0,0,0.06)' }}
          >
            <svg width="15" height="15" viewBox="0 0 15 15" fill="none">
              <path d="M9.5 2.5L5 7.5L9.5 12.5" stroke="#374151" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </button>
          <div className="flex flex-col gap-0.5">
            <p style={{ fontFamily: "'Inter:Extra Bold', sans-serif", fontWeight: 800, fontSize: 22, color: '#1f2937', lineHeight: '28px' }}>成长记录</p>
            <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#9ca3af', lineHeight: '18px' }}>每一次变化，都是成长的痕迹。</p>
          </div>
        </div>
      </div>

      {/* Divider */}
      <div className="mx-5 h-px" style={{ background: '#e8e4f0' }}/>

      {/* Calendar strip */}
      {(() => {
        const now = new Date();
        const todayNum = now.getDate();
        const todayDow = now.getDay();
        const DAY_LABELS = ['日', '一', '二', '三', '四', '五', '六'];
        const days = Array.from({ length: 7 }, (_, i) => {
          const d = new Date(now);
          d.setDate(now.getDate() - todayDow + i);
          return { label: DAY_LABELS[i], date: d.getDate(), isToday: d.getDate() === todayNum && d.getMonth() === now.getMonth() };
        });
        const monthLabel = `${now.getFullYear()}年${now.getMonth() + 1}月`;
        return (
          <div className="flex-shrink-0 px-5 pb-4 pt-3">
            <p style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 12, color: '#9ca3af', letterSpacing: '0.5px', lineHeight: '16px', paddingLeft: 4, paddingBottom: 12 }}>{monthLabel}</p>
            <div className="flex items-start justify-between px-1">
              {days.map((d, i) => (
                <div key={i} className="flex flex-col items-center" style={{ gap: 8, width: 40 }}>
                  <span style={{ fontFamily: d.isToday ? "'Inter:Bold', sans-serif" : "'Inter:Medium', sans-serif", fontWeight: d.isToday ? 700 : 500, fontSize: 11, color: d.isToday ? '#5b6ad0' : '#b0b7c3' }}>{d.label}</span>
                  {d.isToday ? (
                    <div className="flex items-center justify-center" style={{ width: 40, height: 40, borderRadius: 20, backgroundImage: 'linear-gradient(135deg, #6c7ee1 0%, #a07fe8 100%)', boxShadow: '0px 4px 6px rgba(123,126,218,0.25)', flexShrink: 0 }}>
                      <span style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 14, color: 'white' }}>{d.date}</span>
                    </div>
                  ) : (
                    <div className="flex items-center justify-center" style={{ width: 40, height: 40, borderRadius: 20, background: 'white', border: '1px solid #ededf2', flexShrink: 0 }}>
                      <span style={{ fontFamily: "'Inter:Medium', sans-serif", fontWeight: 500, fontSize: 14, color: '#374151' }}>{d.date}</span>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        );
      })()}

      {/* Timeline list */}
      <div className="flex-1 overflow-y-auto pb-10 px-5 pt-3">
        {GROWTH_TIMELINE.map((item, i) => (
          <div key={i} className="flex items-start" style={{ height: i < GROWTH_TIMELINE.length - 1 ? 162 : 154 }}>
            {/* Date label — right-aligned, 56px wide */}
            <div className="flex flex-col items-end flex-shrink-0" style={{ width: 56, paddingTop: 16 }}>
              <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 11, color: '#a0a7b8', letterSpacing: '-0.2px', lineHeight: '16px' }}>
                {item.date.replace('.', '/')}
              </span>
            </div>

            {/* Timeline column — 44px, dot + connector line */}
            <div className="flex flex-col items-center flex-shrink-0" style={{ width: 44, paddingLeft: 14, paddingRight: 14 }}>
              <div style={{ paddingTop: 18 }}>
                <div style={{ width: 10, height: 10, borderRadius: 5, background: dotColor[item.type], boxShadow: `0 0 0 0 ${dotColor[item.type]}30` }}/>
              </div>
              {i < GROWTH_TIMELINE.length - 1 && (
                <div style={{ flex: 1, width: 1.5, marginTop: 5, backgroundImage: `linear-gradient(180deg, ${lineColor[item.type]} 25%, rgba(255,255,255,0) 100%)` }}/>
              )}
            </div>

            {/* Event card */}
            <div className="flex-1 min-w-px" style={{ paddingTop: 8, paddingBottom: 20 }}>
              <div
                style={{
                  background: cardBg[item.type],
                  borderRadius: '4px 20px 20px 20px',
                  padding: 16,
                  display: 'flex', flexDirection: 'column', gap: 10,
                }}
              >
                {/* Card header: circle tag + title + date */}
                <div style={{ height: 42, position: 'relative', flexShrink: 0, width: '100%' }}>
                  {/* Circle tag badge */}
                  <div style={{
                    position: 'absolute', left: 0, top: 0,
                    width: 42, height: 42, borderRadius: 20,
                    background: dotColor[item.type],
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    padding: '14px 11px',
                  }}>
                    <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 10, color: 'white', lineHeight: '14px', width: '100%', textAlign: 'center' }}>{typeLabel[item.type]}</span>
                  </div>
                  {/* Title */}
                  <div style={{ position: 'absolute', left: 52, top: 3, height: 21 }}>
                    <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: '#1f2937', lineHeight: '21px', whiteSpace: 'nowrap' }}>{item.event}</p>
                  </div>
                  {/* Date below title */}
                  <p style={{ position: 'absolute', left: 52, top: 25, fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 11, color: '#a0a7b8', letterSpacing: '-0.2px', lineHeight: '16px', whiteSpace: 'nowrap' }}>
                    {item.date.replace('.', '/')}
                  </p>
                </div>
                {/* Description */}
                <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#6b7280', lineHeight: '20px', width: '100%' }}>{item.desc}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── Swipeable archived resume card ───────────────────────────────────────────
function SwipeableResumeCard({
  r, idx, onSetCurrent, onDelete,
}: {
  r: { v: string; date: string; change: string; match: string };
  idx: number;
  onSetCurrent: () => void;
  onDelete: () => void;
}) {
  const REVEAL = 160;
  const cardRef = useRef<HTMLDivElement>(null);
  const startXRef = useRef(0);
  const currentOffsetRef = useRef(0);
  const isOpenRef = useRef(false);
  const isDraggingRef = useRef(false);

  const applyTransform = (x: number, animated: boolean) => {
    const el = cardRef.current;
    if (!el) return;
    el.style.transition = animated ? 'transform 0.25s cubic-bezier(0.25,0.46,0.45,0.94)' : 'none';
    el.style.transform = `translateX(${x}px)`;
    currentOffsetRef.current = x;
  };

  const snap = (open: boolean) => {
    const target = open ? -REVEAL : 0;
    applyTransform(target, true);
    isOpenRef.current = open;
  };

  const onTouchStart = (e: React.TouchEvent) => {
    startXRef.current = e.touches[0].clientX;
    isDraggingRef.current = true;
  };

  const onTouchMove = (e: React.TouchEvent) => {
    if (!isDraggingRef.current) return;
    const dx = e.touches[0].clientX - startXRef.current;
    const base = isOpenRef.current ? -REVEAL : 0;
    const next = Math.min(0, Math.max(-REVEAL, base + dx));
    applyTransform(next, false);
  };

  const onTouchEnd = () => {
    isDraggingRef.current = false;
    snap(currentOffsetRef.current < -REVEAL / 2);
  };

  const handleClick = () => {
    if (isOpenRef.current) snap(false);
  };

  return (
    <div className="relative overflow-hidden rounded-2xl">
      {/* Action buttons sit behind the card, revealed as card slides left */}
      <div className="absolute inset-y-0 right-0 flex" style={{ width: REVEAL }}>
        <button
          className="flex flex-col items-center justify-center gap-1 flex-1"
          style={{ background: 'linear-gradient(136.47deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)' }}
          onClick={() => { snap(false); onSetCurrent(); }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M5 13L9 17L19 7" stroke="white" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          <span style={{ fontSize: 10, color: 'white', fontWeight: 600, fontFamily: "'Inter:Semi_Bold', 'Inter', sans-serif", lineHeight: '14px' }}>设为当前</span>
        </button>
        <button
          className="flex flex-col items-center justify-center gap-1 flex-1"
          style={{ background: '#FF3B30' }}
          onClick={() => { snap(false); onDelete(); }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          <span style={{ fontSize: 10, color: 'white', fontWeight: 600, lineHeight: '14px' }}>删除</span>
        </button>
      </div>

      {/* Sliding card */}
      <div
        ref={cardRef}
        style={{ background: 'rgba(255,255,255,0.90)', backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)', willChange: 'transform' }}
        onTouchStart={onTouchStart}
        onTouchMove={onTouchMove}
        onTouchEnd={onTouchEnd}
        onClick={handleClick}
      >
        <div className="flex items-center gap-3 p-4">
          <div
            className="flex items-center justify-center flex-shrink-0"
            style={{ width: 44, height: 44, borderRadius: 13, background: idx === 0 ? 'rgba(79,126,245,0.10)' : 'rgba(229,231,235,0.55)' }}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
              <rect x="4" y="2" width="16" height="20" rx="3" stroke={idx === 0 ? S.primaryBlue : S.textSecondary} strokeWidth="1.8"/>
              <path d="M8 8h8M8 12h8M8 16h5" stroke={idx === 0 ? S.primaryBlue : S.textSecondary} strokeWidth="1.8" strokeLinecap="round"/>
            </svg>
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <p style={{ fontSize: 14, fontWeight: 700, fontFamily: "'Inter:Bold', 'Inter', sans-serif", color: S.textPrimary }}>Resume {r.v}</p>
              <span style={{ fontSize: 10, padding: '2px 8px', borderRadius: 99, background: 'rgba(229,231,235,0.70)', color: S.textSecondary, fontWeight: 500, fontFamily: "'Inter:Medium', 'Inter', sans-serif" }}>归档</span>
            </div>
            <p style={{ fontSize: 11, color: S.textSecondary, marginTop: 2 }}>{r.date} · {r.change}</p>
          </div>
          <div className="text-right flex-shrink-0">
            <p style={{ fontSize: 14, fontWeight: 700, ...gradText }}>{r.match}</p>
            <p style={{ fontSize: 10, color: S.textSecondary, marginTop: 2 }}>最高匹配</p>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── Resume Detail (PDF Preview) ─────────────────────────────────────────────

const RESUME_SECTIONS = [
  {
    title: '基本信息',
    items: [
      { label: '姓名', value: '张明远' },
      { label: '职位', value: '高级产品经理' },
      { label: '邮箱', value: 'zhangy@example.com' },
      { label: '电话', value: '+86 138 0000 0000' },
      { label: '地点', value: '上海市' },
    ],
  },
  {
    title: '工作经历',
    items: [
      { label: '字节跳动 · 产品经理', value: '2023.07 — 至今', detail: '负责 AI 产品从 0 到 1 搭建，主导用户增长策略，DAU 提升 42%。' },
      { label: '美团 · 助理产品经理', value: '2021.07 — 2023.06', detail: '负责外卖配送调度系统迭代，优化骑手路径算法，效率提升 18%。' },
      { label: '腾讯 · 产品实习生', value: '2020.09 — 2021.06', detail: '参与微信小程序功能调研与原型设计，输出竞品分析报告 6 份。' },
      { label: '阿里巴巴 · 数据产品实习', value: '2019.06 — 2020.08', detail: '协助搭建数据看板，参与用户行为分析项目。' },
    ],
  },
  {
    title: '项目经历',
    items: [
      { label: 'AI 求职助手 · Careerly', value: '2025.01 — 2026.08', detail: '主导 AI Agent 模块设计，覆盖简历解析、岗位匹配、面试辅导三条链路。' },
      { label: '用户增长平台', value: '2024.03 — 2024.12', detail: '从零搭建增长实验平台，累计运行 A/B 实验 120+ 组，带动注册转化率提升 23%。' },
      { label: '智能客服系统', value: '2023.08 — 2024.02', detail: '引入大模型接入客服场景，自动解决率从 34% 提升至 71%。' },
      { label: '外卖调度优化', value: '2022.01 — 2022.12', detail: '参与骑手智能调度算法产品化，日均节省配送成本 80 万元。' },
      { label: '数据中台建设', value: '2021.03 — 2021.10', detail: '推动数据标准化治理，接入业务线 12 条，减少重复开发 60%。' },
      { label: '微信小程序改版', value: '2020.11 — 2021.03', detail: '负责核心功能重构方案，用户留存率提升 15%。' },
    ],
  },
  {
    title: '技能',
    items: [
      { label: '产品设计', value: 'Figma · Axure · MasterGo' },
      { label: '数据分析', value: 'SQL · Python · Tableau' },
      { label: 'AI / 大模型', value: 'Prompt Engineering · RAG · LangChain' },
      { label: '项目管理', value: 'Jira · Confluence · OKR 拆解' },
      { label: '增长方法论', value: 'A/B 实验 · 用户分层 · 漏斗分析' },
      { label: '语言', value: '普通话（母语）· 英语（CET-6 / 业务流利）' },
      { label: '证书', value: 'PMP · 数据分析师（初级）' },
      { label: '其他', value: 'AI 产品专项培训 · 产品经理集训营结业' },
      { label: '开源贡献', value: 'LLM-Eval GitHub 项目 Star 300+' },
      { label: '个人博客', value: '产品思考周刊，累计阅读 5 万+' },
      { label: '演讲', value: '2026 产品大会演讲嘉宾' },
      { label: '志愿服务', value: '公益产品设计志愿者 · 累计 120h' },
    ],
  },
];

function ResumeDetailPage() {
  const { back, params } = useNav();
  const version = (params.version as string) || 'V3';
  const date = (params.date as string) || '2026.08.27';
  const match = (params.match as string) || '86%';

  const [activeTab, setActiveTab] = useState<'preview' | 'source'>('preview');
  const [showShareSheet, setShowShareSheet] = useState(false);

  const tabs: { key: 'preview' | 'source'; label: string }[] = [
    { key: 'preview', label: 'PDF 预览' },
    { key: 'source', label: '原始内容' },
  ];

  return (
    <div className="flex flex-col h-full relative" style={{ background: '#f5f6fa' }}>
      <TopBar
        title={`Resume ${version}`}
        onBack={back}
        right={
          <button className="active:opacity-60 transition-opacity p-1" onClick={() => setShowShareSheet(true)}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M4 12v7a1 1 0 001 1h14a1 1 0 001-1v-7M12 3v13M8 7l4-4 4 4" stroke="#4F7EF5" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
        }
      />

      {/* Version pill + match badge */}
      <div className="flex items-center justify-between px-5 py-3 shrink-0">
        <div className="flex items-center gap-2">
          <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full" style={{ background: 'rgba(79,126,245,0.10)' }}>
            <div className="w-1.5 h-1.5 rounded-full" style={{ background: '#4F7EF5' }}/>
            <span style={{ fontFamily: "'Inter:Semi_Bold', 'Inter', sans-serif", fontWeight: 600, fontSize: 11, color: '#4F7EF5' }}>当前简历</span>
          </div>
          <span style={{ fontFamily: "'Inter:Regular', 'Inter', sans-serif", fontSize: 11, color: '#9ca3af' }}>更新于 {date}</span>
        </div>
        <div className="flex items-center gap-1">
          <span style={{ fontFamily: "'Inter:Regular', 'Inter', sans-serif", fontSize: 11, color: '#9ca3af' }}>最高匹配</span>
          <span style={{ fontFamily: "'Inter:Bold', 'Inter', sans-serif", fontWeight: 700, fontSize: 13, background: 'linear-gradient(145deg, #4F7EF5 0%, #A77BE6 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>{match}</span>
        </div>
      </div>

      {/* Tab switcher */}
      <div className="flex px-5 gap-2 shrink-0 mb-3">
        {tabs.map(t => (
          <button
            key={t.key}
            onClick={() => setActiveTab(t.key)}
            className="px-4 py-1.5 rounded-full transition-all active:scale-95"
            style={activeTab === t.key
              ? { background: '#373b4d', color: 'white', fontFamily: "'Roboto:SemiBold', 'Roboto', sans-serif", fontWeight: 600, fontSize: 13 }
              : { background: 'rgba(229,231,235,0.60)', color: '#6b7280', fontFamily: "'Inter:Medium', 'Inter', sans-serif", fontWeight: 500, fontSize: 13 }
            }
          >
            {t.label}
          </button>
        ))}
      </div>

      {/* Content area */}
      <div className="flex-1 overflow-y-auto px-4 pb-8">
        {activeTab === 'preview' ? (
          /* ── PDF-style preview ── */
          <div className="rounded-2xl overflow-hidden shadow-[0_4px_24px_rgba(0,0,0,0.10)]" style={{ background: 'white' }}>
            {/* PDF header strip */}
            <div className="px-6 py-5" style={{ background: 'linear-gradient(135deg, #4F7EF5 0%, #A77BE6 100%)' }}>
              <h1 style={{ fontFamily: "'Inter:Bold', 'Inter', sans-serif", fontWeight: 700, fontSize: 22, color: 'white', lineHeight: '28px' }}>张明远</h1>
              <p style={{ fontFamily: "'Inter:Regular', 'Inter', sans-serif", fontSize: 13, color: 'rgba(255,255,255,0.80)', marginTop: 4 }}>高级产品经理 · 上海</p>
              <div className="flex flex-wrap gap-x-4 gap-y-1 mt-3">
                {['zhangy@example.com', '+86 138 0000 0000'].map(v => (
                  <span key={v} style={{ fontFamily: "'Inter:Regular', 'Inter', sans-serif", fontSize: 11, color: 'rgba(255,255,255,0.70)' }}>{v}</span>
                ))}
              </div>
            </div>

            {/* Sections */}
            <div className="divide-y divide-gray-100">
              {RESUME_SECTIONS.slice(1).map(sec => (
                <div key={sec.title} className="px-6 py-4">
                  <div className="flex items-center gap-2 mb-3">
                    <div className="w-1 h-4 rounded-full" style={{ background: 'linear-gradient(180deg, #4F7EF5 0%, #A77BE6 100%)' }}/>
                    <h2 style={{ fontFamily: "'Inter:Bold', 'Inter', sans-serif", fontWeight: 700, fontSize: 13, color: '#111827', letterSpacing: '0.3px' }}>{sec.title}</h2>
                  </div>
                  <div className="space-y-3">
                    {sec.items.map((item, i) => (
                      <div key={i}>
                        <div className="flex items-baseline justify-between">
                          <span style={{ fontFamily: "'Inter:Bold', 'Inter', sans-serif", fontWeight: 700, fontSize: 12, color: '#1f2937' }}>{item.label}</span>
                          <span style={{ fontFamily: "'Inter:Regular', 'Inter', sans-serif", fontSize: 11, color: '#9ca3af' }}>{item.value}</span>
                        </div>
                        {'detail' in item && item.detail && (
                          <p style={{ fontFamily: "'Inter:Regular', 'Inter', sans-serif", fontSize: 11, color: '#6b7280', lineHeight: '17px', marginTop: 2 }}>{item.detail}</p>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>

            {/* PDF footer */}
            <div className="px-6 py-3 flex items-center justify-between" style={{ background: '#fafafa', borderTop: '0.5px solid #f3f4f6' }}>
              <span style={{ fontFamily: "'Inter:Regular', 'Inter', sans-serif", fontSize: 10, color: '#d1d5db' }}>Resume {version} · 由 Careerly 生成</span>
              <span style={{ fontFamily: "'Inter:Regular', 'Inter', sans-serif", fontSize: 10, color: '#d1d5db' }}>第 1 页</span>
            </div>
          </div>
        ) : (
          /* ── Raw content view ── */
          <div className="space-y-3">
            {RESUME_SECTIONS.map(sec => (
              <div key={sec.title} className="rounded-2xl p-4" style={{ background: 'rgba(255,255,255,0.90)', backdropFilter: 'blur(12px)' }}>
                <p style={{ fontFamily: "'Inter:Bold', 'Inter', sans-serif", fontWeight: 700, fontSize: 12, color: '#374151', marginBottom: 10, letterSpacing: '0.3px', textTransform: 'uppercase' }}>{sec.title}</p>
                <div className="space-y-2.5">
                  {sec.items.map((item, i) => (
                    <div key={i} className="flex items-start justify-between gap-3">
                      <span style={{ fontFamily: "'Inter:Medium', 'Inter', sans-serif", fontWeight: 500, fontSize: 12, color: '#374151', flexShrink: 0 }}>{item.label}</span>
                      <span style={{ fontFamily: "'Inter:Regular', 'Inter', sans-serif", fontSize: 12, color: '#6b7280', textAlign: 'right' }}>{item.value}</span>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Bottom action bar */}
      <div
        className="shrink-0 px-5 pb-6 pt-3 flex gap-3"
        style={{ background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)', borderTop: '0.5px solid rgba(0,0,0,0.06)' }}
      >
        <button
          className="flex-1 flex items-center justify-center gap-2 active:scale-95 transition-transform"
          style={{ height: 48, borderRadius: 99, background: 'rgba(79,126,245,0.08)', border: '1px solid rgba(79,126,245,0.20)' }}
          onClick={() => setShowShareSheet(true)}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M4 12v7a1 1 0 001 1h14a1 1 0 001-1v-7M12 3v13M8 7l4-4 4 4" stroke="#4F7EF5" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          <span style={{ fontFamily: "'Inter:Semi_Bold', 'Inter', sans-serif", fontWeight: 600, fontSize: 14, color: '#4F7EF5' }}>导出 PDF</span>
        </button>
        <button
          className="flex-1 flex items-center justify-center gap-2 active:scale-95 transition-transform"
          style={{ height: 48, borderRadius: 99, background: 'linear-gradient(135deg, #4F7EF5 0%, #A77BE6 100%)' }}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M12 20h9M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          <span style={{ fontFamily: "'Inter:Semi_Bold', 'Inter', sans-serif", fontWeight: 600, fontSize: 14, color: 'white' }}>编辑简历</span>
        </button>
      </div>

      {/* Share bottom sheet */}
      {showShareSheet && (
        <div
          className="absolute inset-0 z-50 flex items-end"
          style={{ background: 'rgba(0,0,0,0.40)', backdropFilter: 'blur(6px)' }}
          onClick={() => setShowShareSheet(false)}
        >
          <div
            className="w-full rounded-t-[28px] overflow-hidden"
            style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)' }}
            onClick={e => e.stopPropagation()}
          >
            <div className="flex flex-col items-center px-5 pt-3 pb-8">
              <div style={{ width: 40, height: 4, borderRadius: 9999, background: 'rgba(209,213,219,0.8)', marginBottom: 16 }}/>
              <p style={{ fontFamily: "'Inter:Bold', 'Inter', sans-serif", fontWeight: 700, fontSize: 16, color: '#111827', marginBottom: 20 }}>分享 / 导出</p>
              <div className="w-full flex gap-3">
                {[
                  { icon: <path d="M4 12v7a1 1 0 001 1h14a1 1 0 001-1v-7M12 3v13M8 7l4-4 4 4" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>, label: '存为 PDF', color: '#4F7EF5' },
                  { icon: <path d="M8 6H5a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-3M16 3h5m0 0v5m0-5L10 14" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>, label: '复制链接', color: '#A77BE6' },
                  { icon: <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2zM22 6l-10 7L2 6" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>, label: '发送邮件', color: '#34D399' },
                ].map((item, i) => (
                  <button
                    key={i}
                    className="flex-1 flex flex-col items-center gap-2 py-4 rounded-2xl active:scale-95 transition-transform"
                    style={{ background: `${item.color}15` }}
                    onClick={() => setShowShareSheet(false)}
                  >
                    <div className="w-10 h-10 rounded-full flex items-center justify-center" style={{ background: item.color }}>
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">{item.icon}</svg>
                    </div>
                    <span style={{ fontFamily: "'Inter:Medium', 'Inter', sans-serif", fontWeight: 500, fontSize: 12, color: '#374151' }}>{item.label}</span>
                  </button>
                ))}
              </div>
              <button
                className="w-full flex items-center justify-center mt-4 active:opacity-75 transition-opacity"
                style={{ height: 48, borderRadius: 99, background: 'rgba(55,59,77,0.87)' }}
                onClick={() => setShowShareSheet(false)}
              >
                <span style={{ fontFamily: "'Inter:Semi_Bold', 'Inter', sans-serif", fontWeight: 600, fontSize: 14, color: 'white' }}>取消</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function ResumeHistoryPage() {
  const { back, go } = useNav();
  const [showImport, setShowImport] = useState(false);
  const [currentV, setCurrentV] = useState('V3');
  const [archivedList, setArchivedList] = useState([
    { v: 'V2', date: '2026.05.15', change: '补充用户研究案例', match: '79%' },
    { v: 'V1', date: '2026.01.03', change: '首次创建', match: '68%' },
  ]);

  // Derive current card data
  const allVersions: Record<string, { date: string; change: string; match: string; skills: number; projects: number; experience: number }> = {
    V3: { date: '2026.08.27', change: '新增 AI Agent 项目', match: '86%', skills: 12, projects: 6, experience: 4 },
    V2: { date: '2026.05.15', change: '补充用户研究案例', match: '79%', skills: 9, projects: 4, experience: 3 },
    V1: { date: '2026.01.03', change: '首次创建', match: '68%', skills: 6, projects: 2, experience: 2 },
  };
  const current = { v: currentV, ...allVersions[currentV] };

  return (
    <div className="flex flex-col h-full relative">
      <TopBar title="我的简历" onBack={back}/>

      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-5">

        {/* ── Current resume banner (colored) ── */}
        <div className="rounded-3xl overflow-hidden relative" style={{ background: S.primary }}>
          {/* Decorative circles */}
          <div className="absolute -top-10 -right-10 w-36 h-36 rounded-full" style={{ background: 'rgba(255,255,255,0.07)' }}/>
          <div className="absolute -bottom-8 -left-8 w-28 h-28 rounded-full" style={{ background: 'rgba(255,255,255,0.05)' }}/>

          <div className="relative p-5">
            {/* Badge */}
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full mb-4" style={{ background: 'rgba(255,255,255,0.20)' }}>
              <div className="w-1.5 h-1.5 rounded-full bg-white"/>
              <span className="text-white text-[11px]" style={{ fontFamily: "'Inter:Semi_Bold', 'Inter', sans-serif", fontWeight: 600 }}>当前简历</span>
            </div>

            <div className="flex items-start justify-between mb-4">
              <div>
                <h2 className="text-white font-bold" style={{ fontSize: 22, lineHeight: '28px' }}>Resume {current.v}</h2>
                <p className="text-white/60 text-[12px] mt-1">更新于 {current.date}</p>
                <p className="text-white/75 text-[12px] mt-0.5">{current.change}</p>
              </div>
              {/* Doc icon */}
              <div className="flex items-center justify-center" style={{ width: 48, height: 48, borderRadius: 14, background: 'rgba(255,255,255,0.18)' }}>
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="4" y="2" width="16" height="20" rx="3" stroke="white" strokeWidth="1.7"/><path d="M8 8h8M8 12h8M8 16h5" stroke="white" strokeWidth="1.7" strokeLinecap="round"/></svg>
              </div>
            </div>

            {/* Stats row */}
            <div className="flex gap-3 mb-4">
              {[{ n: current.experience, l: '段经历' }, { n: current.projects, l: '个项目' }, { n: current.skills, l: '项技能' }].map(s => (
                <div key={s.l} className="flex-1 rounded-2xl py-2.5 text-center" style={{ background: 'rgba(255,255,255,0.14)' }}>
                  <p className="text-white font-bold" style={{ fontSize: 17 }}>{s.n}</p>
                  <p className="text-white/65 text-[10px] mt-0.5">{s.l}</p>
                </div>
              ))}
            </div>

            {/* Match badge */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="text-white/60 text-[12px]">最高匹配</span>
                <span className="text-white font-bold text-[15px]">{current.match}</span>
              </div>
              <button
                className="flex items-center justify-center active:scale-95 transition-transform"
                style={{ background: '#373b4d', color: 'white', fontSize: 14, fontWeight: 600, fontFamily: "'Roboto:SemiBold', 'Roboto', sans-serif", borderRadius: 20, width: 100, height: 30 }}
                onClick={() => go('resume-detail', { version: current.v, date: current.date, change: current.change, match: current.match })}
              >
                查看详情
              </button>
            </div>
          </div>
        </div>

        {/* ── Archived versions ── */}
        {archivedList.length > 0 && (
          <div>
            <p className="text-[11px] mb-3 uppercase" style={{ fontFamily: "'Inter:Semi_Bold', 'Inter', sans-serif", fontWeight: 600, letterSpacing: '0.275px', color: S.textSecondary }}>
              历史版本 · 左滑操作
            </p>
            <div className="space-y-2.5">
              {archivedList.map((r, i) => (
                <SwipeableResumeCard
                  key={r.v}
                  r={r}
                  idx={i}
                  onSetCurrent={() => {
                    // Move current to archived, promote this one
                    setArchivedList(prev => {
                      const rest = prev.filter(x => x.v !== r.v);
                      const old = { v: currentV, date: allVersions[currentV].date, change: allVersions[currentV].change, match: allVersions[currentV].match };
                      return [old, ...rest];
                    });
                    setCurrentV(r.v);
                  }}
                  onDelete={() => setArchivedList(prev => prev.filter(x => x.v !== r.v))}
                />
              ))}
            </div>
          </div>
        )}
      </div>

      {/* ── FAB: add / import resume ── */}
      <button
        className="absolute flex items-center justify-center active:scale-90 transition-transform"
        style={{ right: 20, bottom: 28, width: 56, height: 56, borderRadius: '50%', background: S.primary, boxShadow: '0 8px 24px rgba(79,126,245,0.40)' }}
        onClick={() => setShowImport(true)}
      >
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
          <path d="M12 5v14M5 12h14" stroke="white" strokeWidth="2.4" strokeLinecap="round"/>
        </svg>
      </button>

      {/* ── Import bottom sheet ── */}
      {showImport && (
        <div
          className="absolute inset-0 z-50 flex items-end"
          style={{ background: 'rgba(0,0,0,0.40)', backdropFilter: 'blur(6px)' }}
          onClick={() => setShowImport(false)}
        >
          <div
            className="w-full rounded-t-[28px] overflow-hidden"
            style={{ background: 'rgba(255,255,255,0.88)', backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)', boxShadow: '0px -2px 48px rgba(0,0,0,0.18)' }}
            onClick={e => e.stopPropagation()}
          >
            <div className="flex flex-col items-center px-5 pt-3 pb-8">
              {/* Drag handle */}
              <div style={{ width: 40, height: 4, borderRadius: 9999, background: 'rgba(209,213,219,0.8)', marginBottom: 12 }}/>

              {/* Title */}
              <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 17, color: '#111827', lineHeight: '25.5px', textAlign: 'center' }}>导入新简历</p>

              {/* Description */}
              <div style={{ marginTop: 10, marginBottom: 18, textAlign: 'center' }}>
                <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#6b7280', lineHeight: '20px' }}>从手机文件选择 PDF 或 Word 简历，</p>
                <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 13, color: '#6b7280', lineHeight: '20px' }}>Careerly 会自动解析。</p>
              </div>

              {/* Options */}
              <div className="w-full flex flex-col gap-3">
                {/* 从文件选择 */}
                <button
                  className="w-full flex items-center gap-5 active:scale-[0.98] transition-transform"
                  style={{ padding: '10px 20px', borderRadius: 16, background: 'rgba(79,126,245,0.08)', border: '1.25px solid rgba(79,126,245,0.20)' }}
                  onClick={() => setShowImport(false)}
                >
                  <svg width="22" height="22" viewBox="0 0 21.994 21.994" fill="none" style={{ flexShrink: 0 }}>
                    <path d="M1.83283 5.4985C1.83283 5.0124 2.02593 4.54621 2.36966 4.20249C2.71338 3.85877 3.17957 3.66567 3.66567 3.66567H8.24775L10.0806 5.4985H18.3283C18.8144 5.4985 19.2806 5.6916 19.6243 6.03532C19.9681 6.37905 20.1612 6.84524 20.1612 7.33133V16.4955C20.1612 16.9816 19.9681 17.4478 19.6243 17.7915C19.2806 18.1352 18.8144 18.3283 18.3283 18.3283H3.66567C3.17957 18.3283 2.71338 18.1352 2.36966 17.7915C2.02593 17.4478 1.83283 16.9816 1.83283 16.4955V5.4985Z" stroke="#111827" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.64955"/>
                  </svg>
                  <div className="text-left">
                    <p style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 14, color: '#4f7ef5', lineHeight: '21px' }}>从文件选择</p>
                    <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#6b7280', lineHeight: '16.5px' }}>支持 PDF / DOCX</p>
                  </div>
                </button>

                {/* 拍照上传 */}
                <button
                  className="w-full flex items-center gap-5 active:scale-[0.98] transition-transform"
                  style={{ padding: '10px 20px', height: 61, borderRadius: 16, background: 'rgba(229,231,235,0.40)', border: '1.25px solid transparent' }}
                  onClick={() => setShowImport(false)}
                >
                  <svg width="21" height="16" viewBox="0 0 20.65 16.65" fill="none" style={{ flexShrink: 0 }}>
                    <path d="M19.825 10.8247L16.5676 8.25308C16.1717 7.94063 15.6348 7.7651 15.075 7.7651C14.5152 7.7651 13.9783 7.94063 13.5824 8.25308L3.99167 15.8247M2.93611 0.825H17.7139C18.8798 0.825 19.825 1.57119 19.825 2.49167V14.1583C19.825 15.0788 18.8798 15.825 17.7139 15.825H2.93611C1.77018 15.825 0.825 15.0788 0.825 14.1583V2.49167C0.825 1.57119 1.77018 0.825 2.93611 0.825ZM9.26944 5.825C9.26944 6.74547 8.32427 7.49167 7.15833 7.49167C5.9924 7.49167 5.04722 6.74547 5.04722 5.825C5.04722 4.90453 5.9924 4.15833 7.15833 4.15833C8.32427 4.15833 9.26944 4.90453 9.26944 5.825Z" stroke="black" strokeLinecap="round" strokeWidth="1.65"/>
                  </svg>
                  <div className="text-left">
                    <p style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 14, color: '#373b4d', lineHeight: '21px' }}>拍照上传</p>
                    <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#6b7280', lineHeight: '16.5px' }}>拍摄简历照片</p>
                  </div>
                </button>

                {/* 粘贴文本 */}
                <button
                  className="w-full flex items-center gap-5 active:scale-[0.98] transition-transform"
                  style={{ padding: '10px 20px', height: 58, borderRadius: 16, background: 'rgba(229,231,235,0.40)', border: '1.25px solid transparent' }}
                  onClick={() => setShowImport(false)}
                >
                  <svg width="18" height="18" viewBox="0 0 17.65 17.65" fill="none" style={{ flexShrink: 0 }}>
                    <path d="M8.825 0.825V16.825M0.825 8.825H16.825" stroke="#111827" strokeLinecap="round" strokeWidth="1.65"/>
                  </svg>
                  <div className="text-left">
                    <p style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 14, color: '#373b4d', lineHeight: '21px' }}>粘贴文本</p>
                    <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 11, color: '#6b7280', lineHeight: '16.5px' }}>直接粘贴简历内容</p>
                  </div>
                </button>
              </div>

              {/* Cancel button */}
              <button
                className="w-full flex items-center justify-center active:opacity-75 transition-opacity"
                style={{ marginTop: 14, height: 48, borderRadius: 99, background: 'rgba(55,59,77,0.87)' }}
                onClick={() => setShowImport(false)}
              >
                <span style={{ fontFamily: "'Inter:Semi Bold', sans-serif", fontWeight: 600, fontSize: 14, color: 'white', lineHeight: '21px' }}>取消</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function AnalysisHistoryPage() {
  const { go, back } = useNav();

  const history = [
    {
      label: '一次分析 · 10 个岗位',
      date: '2026/9/7',
      jobs: [
        { name: 'AI 产品经理', pct: 86, barW: 69 },
        { name: '产品经理', pct: 82, barW: 66 },
        { name: '数据产品经理', pct: 74, barW: 59 },
      ],
    },
    {
      label: '一次分析 · 3 个岗位',
      date: '2026/9/7',
      jobs: [
        { name: 'AI 产品经理', pct: 86, barW: 69 },
        { name: '产品经理', pct: 82, barW: 66 },
        { name: '数据产品经理', pct: 74, barW: 59 },
      ],
    },
    {
      label: '一次分析 · 3 个岗位',
      date: '2026/9/7',
      jobs: [
        { name: 'AI 产品经理', pct: 86, barW: 69 },
        { name: '产品经理', pct: 82, barW: 66 },
        { name: '数据产品经理', pct: 74, barW: 59 },
      ],
    },
  ];

  // Clock icon SVG
  const ClockSvg = () => (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
      <path d="M6 2.99976V6L8.00016 7.00008M11.0004 6C11.0004 8.76164 8.76164 11.0004 6 11.0004C3.23836 11.0004 0.9996 8.76164 0.9996 6C0.9996 3.23836 3.23836 0.9996 6 0.9996C8.76164 0.9996 11.0004 3.23836 11.0004 6Z" stroke="white" strokeOpacity="0.6" strokeLinecap="round" strokeWidth="1.4"/>
    </svg>
  );

  return (
    <div className="flex flex-col h-full" style={{ backgroundImage: 'linear-gradient(110.97deg, #a77be6 11.5%, #635bdb 46.1%, #5b7cfa 88.5%)' }}>
      {/* Header */}
      <div className="flex-shrink-0 px-5 pt-4 pb-0">
        <div className="flex items-center gap-3 mb-1">
          <button
            onClick={back}
            className="flex items-center justify-center active:opacity-70 transition-opacity flex-shrink-0"
            style={{ width: 32, height: 32, borderRadius: 12, background: 'rgba(255,255,255,0.18)', border: '1px solid rgba(255,255,255,0.25)' }}
          >
            <svg width="15" height="15" viewBox="0 0 15 15" fill="none">
              <path d="M9.5 2.5L5 7.5L9.5 12.5" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </button>
          <div>
            <p style={{ fontFamily: "'Noto Sans SC:Medium', sans-serif", fontWeight: 500, fontSize: 12, color: '#fefefe', lineHeight: '18px' }}>分析</p>
            <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 24, color: 'white', lineHeight: 'normal' }}>职业分析</p>
          </div>
        </div>

        {/* Tab bar */}
        <div className="relative mt-3 mb-3" style={{ height: 44, borderRadius: 1000 }}>
          {/* Glass background */}
          <div className="absolute inset-0 rounded-full" style={{ backdropFilter: 'blur(12px)', background: 'rgba(255,255,255,0.15)', border: '1px solid rgba(255,255,255,0.25)' }}/>
          <div className="absolute inset-1 flex items-center">
            {/* 新建分析 — inactive */}
            <button
              onClick={() => back()}
              className="flex-1 h-full flex items-center justify-center active:opacity-70"
            >
              <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: '#bfbfbf' }}>新建分析</span>
            </button>
            {/* 历史分析 — active */}
            <div className="flex-1 h-full flex items-center justify-center rounded-full" style={{ background: '#373b4d', boxShadow: '0px 2px 4px rgba(79,126,245,0.12)' }}>
              <span style={{ fontFamily: "'Noto Sans SC:Bold', sans-serif", fontWeight: 700, fontSize: 15, color: '#f0f4ff' }}>历史分析</span>
            </div>
          </div>
        </div>

        {/* Description */}
        <p style={{ fontFamily: "'Inter:Regular', sans-serif", fontWeight: 400, fontSize: 14, color: 'rgba(255,255,255,0.8)', lineHeight: '20px', paddingBottom: 12 }}>
          记录你与不同目标岗位之间的变化
        </p>
      </div>

      {/* Analysis cards */}
      <div className="flex-1 overflow-y-auto px-5 pb-8 space-y-4">
        {history.map((h, i) => (
          <div
            key={i}
            style={{
              backdropFilter: 'blur(12px)',
              background: 'rgba(255,255,255,0.09)',
              border: '1px solid rgba(255,255,255,0.2)',
              borderRadius: 28,
              padding: '11px 10px',
              display: 'flex', flexDirection: 'column', gap: 10,
            }}
          >
            {/* Top row: title + plus button */}
            <div className="flex items-center justify-between">
              <p style={{ fontFamily: "'Inter:Bold', sans-serif", fontWeight: 700, fontSize: 22, color: 'white', lineHeight: 'normal', width: 220 }}>{h.label}</p>
              <div style={{ width: 40, height: 40, borderRadius: 22, background: 'white', boxShadow: '0px 4px 6px rgba(0,0,0,0.06)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M8 2V14M2 8H14" stroke="#1A2D2A" strokeLinecap="round" strokeWidth="2"/>
                </svg>
              </div>
            </div>

            {/* Job match bars */}
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              {h.jobs.map((job, ji) => (
                <div key={ji} className="flex items-center gap-2" style={{ height: ji === 0 ? 18 : 22, paddingTop: ji > 0 ? 8 : 0 }}>
                  {/* Job name */}
                  <div style={{ flex: '184 0 0', minWidth: 0 }}>
                    <p style={{
                      fontFamily: ji === 0 ? "'Inter:Medium', sans-serif" : ji === 1 ? "'Noto Sans SC:Regular', sans-serif" : "'Noto Sans SC:DemiLight', sans-serif",
                      fontWeight: ji === 0 ? 500 : ji === 1 ? 400 : 350,
                      fontSize: 12, color: 'white', lineHeight: '18px', whiteSpace: 'nowrap',
                    }}>{job.name}</p>
                  </div>
                  {/* Progress bar track */}
                  <div style={{ width: 80, height: 6, borderRadius: 40822700, background: 'rgba(229,231,235,0.8)', overflow: 'hidden', flexShrink: 0 }}>
                    <div style={{
                      height: '100%', width: job.barW, borderRadius: 40822700,
                      backgroundImage: ji === 0
                        ? 'linear-gradient(175.2deg, #c0d9ff 1.8%, #dce9fb 39.6%, #e5dcfa 100%)'
                        : 'linear-gradient(174.8deg, #dce9fb 0%, #dce9fb 38.5%, #fbe9f1 100%)',
                    }}/>
                  </div>
                  {/* Percentage */}
                  <div style={{ width: 36, textAlign: 'right', flexShrink: 0 }}>
                    <span style={{ fontFamily: "'Roboto:Bold', sans-serif", fontWeight: 700, fontSize: 12, color: 'white', lineHeight: '18px', fontVariationSettings: '"wdth" 100' }}>{job.pct}%</span>
                  </div>
                </div>
              ))}
            </div>

            {/* Bottom row: date + view button */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-1.5">
                <ClockSvg/>
                <span style={{ fontFamily: "'Roboto:Regular', sans-serif", fontWeight: 400, fontSize: 12, color: 'rgba(255,255,255,0.6)', fontVariationSettings: '"wdth" 100' }}>{' '}{h.date}</span>
              </div>
              <button
                onClick={() => i === 0 ? go('a-result') : undefined}
                style={{ background: 'rgba(255,255,255,0.62)', border: '1px solid white', borderRadius: 12, padding: '6px 12px' }}
                className="active:opacity-70 transition-opacity"
              >
                <span style={{ fontFamily: "'Roboto:SemiBold', 'Noto Sans SC:Bold', sans-serif", fontWeight: 600, fontSize: 12, color: 'white', fontVariationSettings: '"wdth" 100' }}>查看分析</span>
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Membership ───────────────────────────────────────────────────────────────
function MembershipPage({ trialCount }: { trialCount: number }) {
  const { back } = useNav();
  const remaining = 3 - trialCount;
  const benefits = [
    { icon: '∞', label: '职业分析', desc: '不限完整职业分析次数' },
    { icon: '✦', label: 'AI 职业顾问', desc: '持续获得 AI 洞察与行动建议' },
    { icon: '↗', label: '能力变化', desc: '持续记录职业能力变化' },
    { icon: '◈', label: '职业资产', desc: '完整保存职业成长记录' },
  ];
  return (
    <div className="flex flex-col h-full">
      <TopBar title="Careerly Pro" onBack={back}/>
      <div className="flex-1 overflow-y-auto px-5 pb-6 space-y-4">
        {/* Header */}
        <div className="rounded-3xl p-6 text-center relative overflow-hidden" style={{ background: S.primary }}>
          <div className="absolute -top-10 -left-10 w-40 h-40 rounded-full" style={{ background: 'rgba(255,255,255,0.08)' }}/>
          <div className="absolute -bottom-10 -right-10 w-40 h-40 rounded-full" style={{ background: 'rgba(255,255,255,0.06)' }}/>
          <div className="relative">
            <p className="text-white/70 text-[12px] font-medium uppercase tracking-widest mb-2">Careerly Pro</p>
            <h1 className="text-white font-bold text-[28px] mb-2">让职业成长持续发生</h1>
            <p className="text-white/65 text-[13px]">不限次数分析 · 持续 AI 陪伴 · 完整成长记录</p>
          </div>
        </div>

        {/* Trial Status */}
        <Card className="p-4">
          <div className="flex items-center justify-between mb-2">
            <p className="text-[14px] font-bold" style={{ color: remaining > 0 ? S.textPrimary : '#FF3B30' }}>
              {remaining > 0 ? '当前免费体验' : '免费次数已用完'}
            </p>
            <span className="text-[14px] font-bold" style={{ color: remaining > 0 ? S.primaryBlue : '#FF3B30' }}>{remaining} / 3 次</span>
          </div>
          <div className="h-2 rounded-full overflow-hidden" style={{ background: 'rgba(229,231,235,0.8)' }}>
            <div className="h-full rounded-full" style={{ width: `${(remaining / 3) * 100}%`, background: remaining > 0 ? S.primary : '#FF3B30' }}/>
          </div>
          {remaining === 0 && (
            <div className="mt-3 space-y-1">
              {[['能力变化', '+12'], ['最高岗位匹配', '86%'], ['已积累资产', '4段 + 6个 + 12项']].map(([l, v]) => (
                <div key={l} className="flex items-center justify-between">
                  <span className="text-[12px]" style={{ color: S.textSecondary }}>{l}</span>
                  <span className="text-[12px] font-bold" style={gradText}>{v}</span>
                </div>
              ))}
            </div>
          )}
        </Card>

        {/* Benefits */}
        <h3 className="text-[15px] font-bold" style={{ color: S.textPrimary }}>Pro 权益</h3>
        <div className="space-y-2.5">
          {benefits.map(b => (
            <Card key={b.label} className="p-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl flex items-center justify-center text-[18px] font-bold flex-shrink-0" style={{ background: S.primary, color: 'white' }}>{b.icon}</div>
                <div>
                  <p className="text-[14px] font-bold" style={{ color: S.textPrimary }}>{b.label}</p>
                  <p className="text-[12px]" style={{ color: S.textSecondary }}>{b.desc}</p>
                </div>
              </div>
            </Card>
          ))}
        </div>

        <PrimaryBtn label="开通 Careerly Pro"/>
        <p className="text-[11px] text-center" style={{ color: S.textSecondary }}>安全支付 · 随时取消 · 不自动续费</p>
      </div>
    </div>
  );
}

// ─── Settings ────────────────────────────────────────────────────────────────
// ── Settings toggle component ─────────────────────────────────────────────────
function SettingsToggle({ value, onChange }: { value: boolean; onChange: () => void }) {
  return (
    <button
      onClick={onChange}
      className="flex-shrink-0 relative transition-all active:scale-95"
      style={{ width: 50, height: 28, borderRadius: 99, background: value ? S.primary : 'rgba(120,120,128,0.20)' }}
    >
      <div
        className="absolute top-1 rounded-full bg-white transition-all"
        style={{ width: 20, height: 20, left: value ? 26 : 4, boxShadow: '0 1px 4px rgba(0,0,0,0.18)' }}
      />
    </button>
  );
}

// ── Settings row ──────────────────────────────────────────────────────────────
function SettingsRow({
  label, value, toggle, onToggle, onPress, last = false,
}: {
  label: string; value?: string; toggle?: boolean; onToggle?: () => void;
  onPress?: () => void; last?: boolean;
}) {
  const inner = (
    <div
      className="flex items-center justify-between"
      style={{ minHeight: 50, paddingLeft: 16, paddingRight: 16, borderBottom: last ? 'none' : `1px solid ${S.divider}` }}
    >
      <span style={{ fontSize: 14, color: '#111827', fontWeight: 400 }}>{label}</span>
      {toggle !== undefined && onToggle ? (
        <SettingsToggle value={toggle} onChange={onToggle}/>
      ) : (
        <div className="flex items-center gap-1">
          {value && <span style={{ fontSize: 14, color: S.textSecondary }}>{value}</span>}
          {onPress && (
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
              <path d="M9 18L15 12L9 6" stroke={S.textSecondary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          )}
        </div>
      )}
    </div>
  );
  return onPress ? (
    <button className="w-full text-left active:bg-black/[0.02] transition-colors" onClick={onPress}>{inner}</button>
  ) : (
    <div>{inner}</div>
  );
}

// ── Settings group card ───────────────────────────────────────────────────────
function SettingsGroup({ children }: { children: React.ReactNode }) {
  return (
    <div className="overflow-hidden rounded-2xl" style={{ background: 'rgba(255,255,255,0.75)', border: '1px solid rgba(255,255,255,0.60)', backdropFilter: 'blur(24px)', WebkitBackdropFilter: 'blur(24px)', boxShadow: '0 4px 20px rgba(79,126,245,0.06)' }}>
      {children}
    </div>
  );
}

function SettingsPage() {
  const { back, logout } = useNav();
  const [notifyOn, setNotifyOn] = useState(true);
  const [aiSuggestion, setAiSuggestion] = useState(true);
  const [dailyBrief, setDailyBrief] = useState(true);
  const [aiContext, setAiContext] = useState(false);
  const [showLogout, setShowLogout] = useState(false);

  return (
    <div className="flex flex-col h-full">
      {/* Header — big title like reference */}
      <div className="flex items-center gap-3 px-5 pt-4 pb-5 flex-shrink-0">
        <button
          onClick={back}
          className="flex items-center justify-center active:scale-90 transition-transform"
          style={{ width: 34, height: 34, borderRadius: 10, ...S.glassLight }}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <path d="M15 18L9 12L15 6" stroke={S.textPrimary} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
        <h1 style={{ fontSize: 24, fontWeight: 800, color: S.textPrimary }}>设置</h1>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-8 space-y-4">

        {/* ── 账户 group ── */}
        <SettingsGroup>
          <SettingsRow label="姓名" value="Alex Chen" onPress={() => {}}/>
          <SettingsRow label="职位" value="产品经理"/>
          <SettingsRow label="邮箱" value="alex@example.com" onPress={() => {}}/>
          <SettingsRow label="工作经验" value="5 年" last/>
        </SettingsGroup>

        {/* ── AI & 通知 toggles ── */}
        <SettingsGroup>
          <SettingsRow label="AI 主动建议" toggle={aiSuggestion} onToggle={() => setAiSuggestion(v => !v)}/>
          <SettingsRow label="每日职业简报" toggle={dailyBrief} onToggle={() => setDailyBrief(v => !v)}/>
          <SettingsRow label="匹配度变化提醒" toggle={notifyOn} onToggle={() => setNotifyOn(v => !v)}/>
          <SettingsRow label="关联职业上下文" toggle={aiContext} onToggle={() => setAiContext(v => !v)} last/>
        </SettingsGroup>

        {/* ── AI 风格 ── */}
        <SettingsGroup>
          <div style={{ padding: '14px 16px' }}>
            <p style={{ fontSize: 12, color: S.textSecondary, marginBottom: 10, fontWeight: 500 }}>AI 回答风格</p>
            <div className="flex gap-2">
              {['简洁', '详细', '行动导向'].map((s, i) => (
                <button
                  key={s}
                  className="flex-1 active:scale-95 transition-transform"
                  style={{
                    height: 34, borderRadius: 99, fontSize: 12, fontWeight: 600,
                    background: i === 0 ? S.primary : 'rgba(229,231,235,0.60)',
                    color: i === 0 ? 'white' : S.textSecondary,
                  }}
                >
                  {s}
                </button>
              ))}
            </div>
          </div>
        </SettingsGroup>

        {/* ── 隐私 & 关于 group ── */}
        <SettingsGroup>
          <SettingsRow label="隐私与数据" onPress={() => {}}/>
          <SettingsRow label="帮助中心" onPress={() => {}}/>
          <SettingsRow label="关于 Careerly" value="v2.0" onPress={() => {}} last/>
        </SettingsGroup>

        {/* ── Logout ── */}
        <button
          className="w-full font-semibold text-[14px] active:scale-[0.98] transition-transform flex items-center justify-center"
          style={{ background: 'rgba(255,59,48,0.07)', color: '#FF3B30', border: '1px solid rgba(255,59,48,0.15)', borderRadius: 16, height: 50 }}
          onClick={() => setShowLogout(true)}
        >
          退出登录
        </button>
        <p className="text-center" style={{ fontSize: 11, color: S.textSecondary }}>退出后本地数据将保留</p>
      </div>

      {/* Logout confirm sheet */}
      {showLogout && (
        <div
          className="absolute inset-0 z-50 flex items-end"
          style={{ background: 'rgba(0,0,0,0.40)', backdropFilter: 'blur(6px)' }}
          onClick={() => setShowLogout(false)}
        >
          <div className="w-full rounded-t-3xl p-6 space-y-4" style={S.glass} onClick={e => e.stopPropagation()}>
            <div className="w-10 h-1 rounded-full mx-auto mb-2" style={{ background: 'rgba(209,213,219,0.8)' }}/>
            <div className="w-12 h-12 rounded-2xl flex items-center justify-center mx-auto" style={{ background: 'rgba(255,59,48,0.10)' }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M16 17l5-5-5-5M21 12H9M13 7V4a1 1 0 0 0-1-1H5a1 1 0 0 0-1 1v16a1 1 0 0 0 1 1h7a1 1 0 0 0 1-1v-3" stroke="#FF3B30" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </div>
            <div className="text-center">
              <h2 style={{ fontSize: 18, fontWeight: 700, color: S.textPrimary, marginBottom: 6, fontFamily: "'Noto Sans SC', sans-serif" }}>确认退出登录？</h2>
              <p style={{ fontSize: 13, color: S.textSecondary, lineHeight: '20px', fontFamily: "'Noto Sans SC', sans-serif", fontWeight: 400 }}>退出后将返回欢迎界面，本地数据将保留。</p>
            </div>
            <div className="space-y-2.5 pt-1">
              <button
                className="w-full flex items-center justify-center active:scale-[0.98] transition-transform"
                style={{ background: 'rgba(255,59,48,0.10)', color: '#FF3B30', border: '1.217px solid rgba(255,59,48,0.20)', borderRadius: 99, height: 48, fontFamily: "'Noto Sans SC', sans-serif", fontWeight: 700, fontSize: 15 }}
                onClick={logout}
              >
                退出登录
              </button>
              <button
                className="w-full flex items-center justify-center active:scale-[0.98] transition-transform"
                style={{ background: 'rgba(55,59,77,0.87)', color: '#ffffff', borderRadius: 99, height: 48, fontFamily: "'Noto Sans SC', sans-serif", fontWeight: 600, fontSize: 14 }}
                onClick={() => setShowLogout(false)}
              >
                取消
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIALOGS
// ═══════════════════════════════════════════════════════════════════════════════

function DialogOverlay({ children, onDismiss }: { children: React.ReactNode; onDismiss: () => void }) {
  return (
    <div className="absolute inset-0 z-50 flex items-end justify-center" style={{ background: 'rgba(0,0,0,0.45)', backdropFilter: 'blur(4px)' }} onClick={onDismiss}>
      <div className="w-full" onClick={e => e.stopPropagation()}>
        {children}
      </div>
    </div>
  );
}

function QuotaDoneDialog({ onClose, onUpgrade }: { onClose: () => void; onUpgrade: () => void }) {
  return (
    <DialogOverlay onDismiss={onClose}>
      <div className="rounded-t-3xl p-6 space-y-4" style={S.glass}>
        <div className="w-12 h-12 rounded-2xl flex items-center justify-center mx-auto" style={{ background: 'rgba(255,149,0,0.15)' }}>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke={S.orange} strokeWidth="2"/><path d="M12 7v6M12 17v.5" stroke={S.orange} strokeWidth="2.5" strokeLinecap="round"/></svg>
        </div>
        <div className="text-center">
          <h2 className="text-[18px] font-bold mb-1" style={{ color: S.textPrimary }}>你的免费体验已用完</h2>
          <p className="text-[13px] leading-relaxed" style={{ color: S.textSecondary }}>
            你已经完成 3 次完整职业分析。继续分析可以持续追踪能力变化、岗位匹配变化和 AI 洞察。
          </p>
        </div>
        <div className="space-y-2.5 pt-2">
          <PrimaryBtn label="升级 Careerly Pro" onClick={onUpgrade}/>
          <SecondaryBtn label="稍后再说" onClick={onClose}/>
        </div>
        <div className="w-12 h-1 rounded-full mx-auto" style={{ background: 'rgba(229,231,235,0.8)' }}/>
      </div>
    </DialogOverlay>
  );
}

function LastTrialDialog({ onClose, onConfirm }: { onClose: () => void; onConfirm: () => void }) {
  return (
    <DialogOverlay onDismiss={onClose}>
      <div className="rounded-t-3xl p-6 space-y-4" style={S.glass}>
        <div className="w-12 h-12 rounded-2xl flex items-center justify-center mx-auto" style={{ background: 'rgba(79,126,245,0.12)' }}>
          <span className="text-[24px]">⏳</span>
        </div>
        <div className="text-center">
          <h2 className="text-[18px] font-bold mb-1" style={{ color: S.textPrimary }}>最后 1 次免费体验</h2>
          <p className="text-[13px] leading-relaxed" style={{ color: S.textSecondary }}>
            完成这次分析后，你可以看到最新的能力与岗位匹配变化。
          </p>
        </div>
        <div className="rounded-2xl p-3 flex items-center justify-between" style={{ background: 'rgba(79,126,245,0.08)' }}>
          <span className="text-[13px] font-semibold" style={{ color: S.primaryBlue }}>剩余次数</span>
          <span className="text-[15px] font-bold" style={{ color: S.primaryBlue }}>1 / 3</span>
        </div>
        <div className="space-y-2.5">
          <PrimaryBtn label="开始分析" onClick={onConfirm}/>
          <SecondaryBtn label="取消" onClick={onClose}/>
        </div>
        <div className="w-12 h-1 rounded-full mx-auto" style={{ background: 'rgba(229,231,235,0.8)' }}/>
      </div>
    </DialogOverlay>
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// APP ROUTER
// ═══════════════════════════════════════════════════════════════════════════════

const ONBOARDING_SCREENS: NavScreen[] = ['on-splash', 'on-register', 'on-welcome', 'on-resume', 'on-parsing', 'on-confirm'];

type TransitionDir = 'tab' | 'push' | 'pop' | 'onboard' | 'none';

export default function App() {
  const [stack, setStack] = useState<{ screen: NavScreen; params: NavParams }[]>([{ screen: 'on-splash', params: {} }]);
  const [tab, setTab] = useState<Tab>('home');
  const [messages, setMessages] = useState<Message[]>(INIT_MSGS);
  const [trialCount, setTrialCount] = useState(0);
  const [dialog, setDialog] = useState<Dialog>('none');
  const [pageKey, setPageKey] = useState(0);
  const [transDir, setTransDir] = useState<TransitionDir>('none');

  const current = stack[stack.length - 1];
  const screen = current.screen;
  const params = current.params;

  const go = (s: NavScreen, p: NavParams = {}) => {
    if (MAIN_TABS.includes(s)) {
      setTransDir('tab');
      setTab(s as Tab);
      setStack([{ screen: s, params: p }]);
    } else if (ONBOARDING_SCREENS.includes(s)) {
      setTransDir('onboard');
      setStack(prev => [...prev, { screen: s, params: p }]);
    } else {
      setTransDir('push');
      setStack(prev => [...prev, { screen: s, params: p }]);
    }
    setPageKey(k => k + 1);
  };

  const back = () => {
    if (stack.length > 1) {
      setTransDir('pop');
      setPageKey(k => k + 1);
      setStack(prev => prev.slice(0, -1));
    }
  };

  const setTabNav = (t: Tab) => {
    setTransDir('tab');
    setPageKey(k => k + 1);
    setTab(t);
    setStack([{ screen: t as NavScreen, params: {} }]);
  };

  const logout = () => {
    setMessages(INIT_MSGS);
    setTrialCount(0);
    setDialog('none');
    setTab('home');
    setStack([{ screen: 'on-splash', params: {} }]);
  };

  const handleProceedAnalysis = () => {
    setTrialCount(c => c + 1);
    setDialog('none');
    go('a-processing');
  };

  const showBottomNav = MAIN_TABS.includes(screen) || screen === 'a-result';
  const hideStatusBar = screen === 'on-splash';
  const lightStatusBar = ['growth-record', 'analysis-history', 'a-processing', 'on-register', 'on-career', 'on-welcome', 'on-resume', 'on-parsing', 'on-confirm'].includes(screen);

  return (
    <NavCtx.Provider value={{ screen, params, go, back, logout }}>
      <div className="w-full min-h-screen flex items-center justify-center" style={{ background: 'rgb(210,222,240)' }}>
        <div className="relative w-full max-w-[390px] flex flex-col overflow-hidden" style={{ height: '100dvh', maxHeight: '844px', background: S.bg }}>
          {!hideStatusBar && <StatusBar light={lightStatusBar}/>}

          {/* Content */}
          <div className={`flex-1 ${screen === 'a-processing' ? 'overflow-visible' : 'overflow-hidden'} ${screen === 'ai' ? 'flex flex-col' : ''}`} style={{ position: 'relative' }}>
            {screen !== 'ai' ? (
              <div
                key={pageKey}
                className={`h-full ${screen === 'a-processing' ? '' : 'overflow-y-auto'} ${showBottomNav ? 'pb-24' : ''} page-${transDir === 'none' ? 'tab' : transDir}`}
              >
                {/* Onboarding */}
                {screen === 'on-splash' && <OnSplash/>}
                {screen === 'on-register' && <OnRegister/>}
                {screen === 'on-career' && <OnCareer/>}
                {screen === 'on-welcome' && <OnWelcome/>}
                {screen === 'on-resume' && <OnResume/>}
                {screen === 'on-parsing' && <OnParsing/>}
                {screen === 'on-confirm' && <OnConfirm/>}
                {/* Home */}
                {screen === 'home' && <HomePage onAnalysisClick={() => go('analysis')} onAIClick={() => setTabNav('ai')} onGrowthClick={() => go('cap-change')}/>}
                {/* Analysis */}
                {screen === 'analysis' && <AnalysisHome trialCount={trialCount} onShowDialog={setDialog}/>}
                {screen === 'a-start' && <AnalysisStartPage/>}
                {screen === 'a-resume-step' && <AnalysisResumeStep onShowDialog={setDialog} trialCount={trialCount}/>}
                {screen === 'a-jd-step' && <AnalysisResumeStep onShowDialog={setDialog} trialCount={trialCount}/>}
                {screen === 'a-confirm' && <AnalysisResumeStep onShowDialog={setDialog} trialCount={trialCount}/>}
                {screen === 'a-resume' && <AnalysisResumePage/>}
                {screen === 'a-targets' && <AnalysisTargetsPage/>}
                {screen === 'a-processing' && <AnalysisProcessing onDone={() => { setTab('analysis'); go('a-result'); }} onStop={() => go('analysis')}/>}
                {screen === 'a-result' && <AnalysisResult/>}
                {screen === 'a-job' && <AnalysisJobDetailPage/>}
                {screen === 'a-gap' && <AnalysisGapPage/>}
                {/* Profile */}
                {screen === 'profile' && <ProfilePage trialCount={trialCount}/>}
                {screen === 'career-assets' && <CareerAssetsPage/>}
                {screen === 'work-exp' && <WorkExperiencePage/>}
                {screen === 'work-detail' && <WorkDetailPage/>}
                {screen === 'projects' && <ProjectExperiencePage/>}
                {screen === 'project-detail' && <ProjectDetailPage/>}
                {screen === 'skills' && <SkillsPage/>}
                {screen === 'awards' && <AwardsPage/>}
                {screen === 'capability' && <CapabilityPage/>}
                {screen === 'cap-change' && <CapabilityChangePage/>}
                {screen === 'growth-record' && <GrowthRecordPage/>}
                {screen === 'resume-history' && <ResumeHistoryPage/>}
                {screen === 'resume-detail' && <ResumeDetailPage/>}
                {screen === 'analysis-history' && <AnalysisHistoryPage/>}
                {screen === 'membership' && <MembershipPage trialCount={trialCount}/>}
                {screen === 'settings' && <SettingsPage/>}
              </div>
            ) : (
              <AIPage messages={messages} setMessages={setMessages}/>
            )}
          </div>

          {/* Bottom Nav — absolute over phone container, zero flex impact */}
          {showBottomNav && (
            <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 50, pointerEvents: 'none' }}>
              <BottomNav tab={tab} setTab={setTabNav}/>
            </div>
          )}

          {/* Dialogs */}
          {dialog === 'quota-done' && (
            <QuotaDoneDialog
              onClose={() => setDialog('none')}
              onUpgrade={() => { setDialog('none'); go('membership'); }}
            />
          )}
          {dialog === 'last-trial' && (
            <LastTrialDialog
              onClose={() => setDialog('none')}
              onConfirm={handleProceedAnalysis}
            />
          )}
        </div>
      </div>
    </NavCtx.Provider>
  );
}
