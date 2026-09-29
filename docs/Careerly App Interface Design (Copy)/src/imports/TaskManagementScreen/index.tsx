import svgPaths from "./svg-0ek5iij3gi";

function IosSignal() {
  return (
    <div className="h-[11px] relative shrink-0 w-[17px]" data-name="ios-signal">
      <svg className="absolute block inset-0 size-full" fill="none" height="11" preserveAspectRatio="none" viewBox="0 0 17 11" width="17">
        <g id="ios-signal">
          <path clipRule="evenodd" d={svgPaths.p2d6ad970} fill="#1E1F22" fillRule="evenodd" id="Vector" />
        </g>
      </svg>
    </div>
  );
}

function IosWifiSignal() {
  return (
    <div className="h-[11px] relative shrink-0 w-[15px]" data-name="ios-wifi-signal">
      <svg className="absolute block inset-0 size-full" fill="none" height="11" preserveAspectRatio="none" viewBox="0 0 15 11" width="15">
        <g id="ios-wifi-signal">
          <path clipRule="evenodd" d={svgPaths.p190a1500} fill="#1E1F22" fillRule="evenodd" id="Vector" />
        </g>
      </svg>
    </div>
  );
}

function IosBatteryFull() {
  return (
    <div className="h-[12px] relative shrink-0 w-[25px]" data-name="ios-battery-full">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 25 12" width="25">
        <g id="ios-battery-full">
          <path d={svgPaths.pde03700} fill="#1E1F22" id="Vector" />
        </g>
      </svg>
    </div>
  );
}

function Icons() {
  return (
    <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-name="Icons">
      <IosSignal />
      <IosWifiSignal />
      <IosBatteryFull />
    </div>
  );
}

function StatusBar() {
  return (
    <div className="absolute content-stretch flex h-[44px] items-center justify-between left-0 pb-[8px] pt-[14px] px-[24px] right-0 top-0" data-name="Status Bar">
      <p className="[word-break:break-word] font-['Roboto:SemiBold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[#1e1f22] text-[15px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        9:41
      </p>
      <Icons />
    </div>
  );
}

function Left() {
  return (
    <div className="col-1 content-stretch flex flex-col items-start justify-self-stretch relative row-1 self-stretch shrink-0" data-name="Left">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[normal] relative shrink-0 text-[#1e1f22] text-[22px] w-[94px]">职业资产</p>
    </div>
  );
}

function Bell() {
  return (
    <div className="relative shrink-0 size-[16px]" data-name="bell">
      <svg className="absolute block inset-0 size-full" fill="none" height="16" preserveAspectRatio="none" viewBox="0 0 16 16" width="16">
        <g id="bell">
          <path d={svgPaths.p1033e080} id="Vector" stroke="#1E1F22" strokeLinecap="round" strokeWidth="2" />
        </g>
      </svg>
    </div>
  );
}

function IconBell() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center overflow-clip relative shrink-0 size-[18px]" data-name="icon-bell">
      <Bell />
    </div>
  );
}

function IconButton() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[20px] shrink-0 size-[40px]" data-name="Icon Button">
      <div aria-hidden className="absolute border border-[#eaeafa] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <IconBell />
    </div>
  );
}

function Right() {
  return (
    <div className="col-2 content-stretch flex items-start justify-self-stretch relative row-1 self-stretch shrink-0" data-name="Right">
      <IconButton />
    </div>
  );
}

function Header() {
  return (
    <div className="absolute gap-x-[254px] gap-y-px grid grid-cols-[repeat(2,minmax(0,1fr))] grid-rows-[repeat(2,minmax(0,1fr))] h-[85px] left-0 px-[24px] py-[4px] right-0 top-[44px]" data-name="Header">
      <Left />
      <Right />
      <p className="[word-break:break-word] col-[1/span_2] font-['Inter:Regular',sans-serif] font-normal justify-self-stretch leading-[0] not-italic relative row-2 self-stretch shrink-0 text-[#6b7280] text-[13px]">
        <span className="font-['Roboto:Regular',sans-serif] leading-[19.5px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` AI `}</span>
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[19.5px]">对你的简历和职业经历的持续记录与分析。</span>
      </p>
    </div>
  );
}

function Icon() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="Icon">
          <path d={svgPaths.p2becf00} id="Vector" stroke="#111827" strokeWidth="1.64955" />
          <path d={svgPaths.p1af21b00} id="Vector_2" stroke="#111827" strokeLinecap="round" strokeWidth="1.64955" />
        </g>
      </svg>
    </div>
  );
}

function ArrowCircle() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[18px] shrink-0 size-[36px]" data-name="Arrow Circle">
      <Icon />
    </div>
  );
}

function ActionArea() {
  return (
    <div className="content-stretch flex gap-[10px] items-center relative shrink-0" data-name="Action Area">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[#a2d84c] text-[12px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        3 段职业经历
      </p>
      <ArrowCircle />
    </div>
  );
}

function TopRow() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Top Row">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[1.3] relative shrink-0 text-[20px] text-white w-[200px]">工作经历</p>
      <ActionArea />
    </div>
  );
}

function Clock() {
  return (
    <div className="relative shrink-0 size-[12px]" data-name="clock">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 12 12" width="12">
        <g clipPath="url(#clip0_0_19)" id="clock">
          <path d={svgPaths.pd1f6ec0} id="Vector" stroke="white" strokeLinecap="round" strokeOpacity="0.6" strokeWidth="2" />
        </g>
        <defs>
          <clipPath id="clip0_0_19">
            <rect fill="white" height="12" width="12" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function IconClock() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center overflow-clip relative shrink-0 size-[14px]" data-name="icon-clock">
      <Clock />
    </div>
  );
}

function TimeInfo() {
  return (
    <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-name="Time Info">
      <IconClock />
      <p className="[word-break:break-word] font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0 text-[12px] text-[rgba(255,255,255,0.68)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        2021/6/8 - 2026/9/9
      </p>
    </div>
  );
}

function PriorityBadge() {
  return (
    <div className="bg-[rgba(255,255,255,0.62)] content-stretch flex items-start px-[12px] py-[6px] relative rounded-[12px] shrink-0" data-name="Priority Badge">
      <div aria-hidden className="absolute border border-solid border-white inset-0 pointer-events-none rounded-[12px]" />
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[12px] text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        查看全部
      </p>
    </div>
  );
}

function BottomRow() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full" data-name="Bottom Row">
      <TimeInfo />
      <PriorityBadge />
    </div>
  );
}

function DarkCard() {
  return (
    <div className="bg-[#373b4d] content-stretch flex flex-col gap-[20px] items-start overflow-clip p-[20px] relative rounded-[24px] shadow-[0px_8px_16px_0px_rgba(0,0,0,0.06)] shrink-0 w-full" data-name="Dark Card">
      <TopRow />
      <BottomRow />
    </div>
  );
}

function TaskGroup() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Task Group 1">
      <DarkCard />
    </div>
  );
}

function Icon2() {
  return (
    <div className="absolute inset-[9.08%_9.16%_13.71%_13.63%]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="16.982" preserveAspectRatio="none" viewBox="0 0 16.982 16.982" width="16.982">
        <g id="Icon">
          <path d={svgPaths.p2f03d000} id="Vector" stroke="#201E22" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.20289" />
        </g>
      </svg>
    </div>
  );
}

function Icon1() {
  return (
    <div className="overflow-clip relative shrink-0 size-[21.994px]" data-name="Icon">
      <Icon2 />
    </div>
  );
}

function ArrowCircle1() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[18px] shrink-0 size-[36px]" data-name="Arrow Circle">
      <Icon1 />
    </div>
  );
}

function ActionArea1() {
  return (
    <div className="content-stretch flex gap-[10px] items-center relative shrink-0" data-name="Action Area">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[#171827] text-[12px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        4 个项目经历
      </p>
      <ArrowCircle1 />
    </div>
  );
}

function TopRow1() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Top Row">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[1.3] relative shrink-0 text-[#171827] text-[20px] w-[200px]">项目经历</p>
      <ActionArea1 />
    </div>
  );
}

function Clock1() {
  return (
    <div className="relative shrink-0 size-[12px]" data-name="clock">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 12 12" width="12">
        <g clipPath="url(#clip0_0_32)" id="clock">
          <path d={svgPaths.pd1f6ec0} id="Vector" stroke="#1E1F22" strokeLinecap="round" strokeOpacity="0.6" strokeWidth="2" />
        </g>
        <defs>
          <clipPath id="clip0_0_32">
            <rect fill="white" height="12" width="12" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function IconClock1() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center overflow-clip relative shrink-0 size-[14px]" data-name="icon-clock">
      <Clock1 />
    </div>
  );
}

function TimeInfo1() {
  return (
    <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-name="Time Info">
      <IconClock1 />
      <p className="[word-break:break-word] font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0 text-[12px] text-[rgba(30,31,34,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        2021/6/8 - 2026/9/9
      </p>
    </div>
  );
}

function PriorityBadge1() {
  return (
    <div className="bg-[rgba(255,255,255,0.62)] content-stretch flex items-start px-[12px] py-[6px] relative rounded-[12px] shrink-0" data-name="Priority Badge">
      <div aria-hidden className="absolute border border-solid border-white inset-0 pointer-events-none rounded-[12px]" />
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[#171827] text-[12px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        查看全部
      </p>
    </div>
  );
}

function BottomRow1() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full" data-name="Bottom Row">
      <TimeInfo1 />
      <PriorityBadge1 />
    </div>
  );
}

function LimeCard() {
  return (
    <div className="bg-[#f1f2f6] content-stretch flex flex-col gap-[20px] items-start overflow-clip p-[20px] relative rounded-[24px] shrink-0 w-full" data-name="Lime Card">
      <TopRow1 />
      <BottomRow1 />
    </div>
  );
}

function Icon3() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="Icon">
          <path d={svgPaths.p18b03500} id="Vector" stroke="#7B5CCC" strokeLinejoin="round" strokeWidth="1.64955" />
        </g>
      </svg>
    </div>
  );
}

function ArrowCircle2() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[18px] shrink-0 size-[36px]" data-name="Arrow Circle">
      <Icon3 />
    </div>
  );
}

function ActionArea2() {
  return (
    <div className="content-stretch flex gap-[10px] items-center relative shrink-0" data-name="Action Area">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[#1e1f22] text-[12px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        12项目技能
      </p>
      <ArrowCircle2 />
    </div>
  );
}

function TopRow2() {
  return (
    <div className="content-stretch flex h-[36px] items-start justify-between relative shrink-0 w-full" data-name="Top Row">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[1.3] relative shrink-0 text-[20px] text-white w-[200px]">专业技能</p>
      <ActionArea2 />
    </div>
  );
}

function Clock2() {
  return (
    <div className="relative shrink-0 size-[12px]" data-name="clock">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 12 12" width="12">
        <g clipPath="url(#clip0_0_32)" id="clock">
          <path d={svgPaths.pd1f6ec0} id="Vector" stroke="#1E1F22" strokeLinecap="round" strokeOpacity="0.6" strokeWidth="2" />
        </g>
        <defs>
          <clipPath id="clip0_0_32">
            <rect fill="white" height="12" width="12" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function IconClock2() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center overflow-clip relative shrink-0 size-[14px]" data-name="icon-clock">
      <Clock2 />
    </div>
  );
}

function TimeInfo2() {
  return (
    <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-name="Time Info">
      <IconClock2 />
      <p className="[word-break:break-word] font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0 text-[12px] text-[rgba(30,31,34,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        2021/6/8 - 2026/9/9
      </p>
    </div>
  );
}

function PriorityBadge2() {
  return (
    <div className="bg-[rgba(255,255,255,0.62)] content-stretch flex items-start px-[12px] py-[6px] relative rounded-[12px] shrink-0" data-name="Priority Badge">
      <div aria-hidden className="absolute border border-solid border-white inset-0 pointer-events-none rounded-[12px]" />
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[#1e1f22] text-[12px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        查看全部
      </p>
    </div>
  );
}

function BottomRow2() {
  return (
    <div className="content-stretch flex h-[26px] items-center justify-between relative shrink-0 w-full" data-name="Bottom Row">
      <TimeInfo2 />
      <PriorityBadge2 />
    </div>
  );
}

function Container() {
  return (
    <div className="content-stretch flex flex-col gap-[20px] items-start overflow-clip p-[20px] relative rounded-[24px] shadow-[0px_8px_24px_0px_rgba(79,126,245,0.25)] shrink-0 w-[390px]" style={{ backgroundImage: "linear-gradient(162.6292466694657deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <TopRow2 />
      <BottomRow2 />
    </div>
  );
}

function Icon4() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="Icon">
          <path d={svgPaths.pab9b700} id="Vector" stroke="#C44B8A" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.64955" />
        </g>
      </svg>
    </div>
  );
}

function ArrowCircle3() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[18px] shrink-0 size-[36px]" data-name="Arrow Circle">
      <Icon4 />
    </div>
  );
}

function ActionArea3() {
  return (
    <div className="content-stretch flex gap-[10px] items-center relative shrink-0" data-name="Action Area">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[#1e1f22] text-[12px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        3 项荣誉记录
      </p>
      <ArrowCircle3 />
    </div>
  );
}

function TopRow3() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Top Row">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[1.3] relative shrink-0 text-[20px] text-white w-[200px]">荣誉成果</p>
      <ActionArea3 />
    </div>
  );
}

function Clock3() {
  return (
    <div className="relative shrink-0 size-[12px]" data-name="clock">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 12 12" width="12">
        <g clipPath="url(#clip0_0_32)" id="clock">
          <path d={svgPaths.pd1f6ec0} id="Vector" stroke="#1E1F22" strokeLinecap="round" strokeOpacity="0.6" strokeWidth="2" />
        </g>
        <defs>
          <clipPath id="clip0_0_32">
            <rect fill="white" height="12" width="12" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function IconClock3() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center overflow-clip relative shrink-0 size-[14px]" data-name="icon-clock">
      <Clock3 />
    </div>
  );
}

function TimeInfo3() {
  return (
    <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-name="Time Info">
      <IconClock3 />
      <p className="[word-break:break-word] font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0 text-[12px] text-[rgba(30,31,34,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        2021/6/8 - 2026/9/9
      </p>
    </div>
  );
}

function PriorityBadge3() {
  return (
    <div className="bg-[rgba(255,255,255,0.62)] content-stretch flex items-start px-[12px] py-[6px] relative rounded-[12px] shrink-0" data-name="Priority Badge">
      <div aria-hidden className="absolute border border-solid border-white inset-0 pointer-events-none rounded-[12px]" />
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[#1e1f22] text-[12px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        查看全部
      </p>
    </div>
  );
}

function BottomRow3() {
  return (
    <div className="content-stretch flex h-[26px] items-center justify-between relative shrink-0 w-full" data-name="Bottom Row">
      <TimeInfo3 />
      <PriorityBadge3 />
    </div>
  );
}

function LimeCard1() {
  return (
    <div className="bg-[#c3aff1] content-stretch flex flex-col gap-[20px] items-start overflow-clip p-[20px] relative rounded-[24px] shrink-0 w-full" data-name="Lime Card">
      <TopRow3 />
      <BottomRow3 />
    </div>
  );
}

function Icon5() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="Icon">
          <path d={svgPaths.p42cc200} id="Vector" stroke="#111827" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.64955" />
        </g>
      </svg>
    </div>
  );
}

function ArrowCircle4() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[18px] shrink-0 size-[36px]" data-name="Arrow Circle">
      <Icon5 />
    </div>
  );
}

function ActionArea4() {
  return (
    <div className="content-stretch flex gap-[10px] items-center relative shrink-0" data-name="Action Area">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[#a2d84c] text-[12px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        点击查看
      </p>
      <ArrowCircle4 />
    </div>
  );
}

function TopRow4() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Top Row">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[1.3] relative shrink-0 text-[#b4c481] text-[20px] w-[200px]">职业能力画像</p>
      <ActionArea4 />
    </div>
  );
}

function ProgressFill() {
  return (
    <div className="bg-[#cadb8f] content-stretch flex h-full items-center pl-[12px] relative shrink-0 w-[180px]" data-name="Progress Fill">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] opacity-62 relative shrink-0 text-[11px] text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        你的资产正在成就你的能力
      </p>
    </div>
  );
}

function ProgressTrack() {
  return (
    <div className="bg-[#e1e2e8] content-stretch flex h-[24px] items-start overflow-clip relative rounded-[12px] shrink-0 w-full" data-name="Progress Track">
      <ProgressFill />
    </div>
  );
}

function ProgressContainer() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Progress Container">
      <ProgressTrack />
    </div>
  );
}

function Text() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[72px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">产品规划</p>
    </div>
  );
}

function Container3() {
  return <div className="h-[5px] relative rounded-[39856500px] shrink-0 w-[161px]" style={{ backgroundImage: "linear-gradient(178.22119968432617deg, rgb(202, 219, 143) 2.4038%, rgb(162, 216, 76) 100%)" }} data-name="Container" />;
}

function Container2() {
  return (
    <div className="bg-[rgba(79,126,245,0.1)] content-stretch flex flex-[176_0_0] flex-col h-[5px] items-start min-w-px overflow-clip relative rounded-[39856500px]" data-name="Container">
      <Container3 />
    </div>
  );
}

function Text1() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[22px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[16.5px] not-italic relative shrink-0 text-[#111827] text-[11px] text-right whitespace-nowrap">85</p>
    </div>
  );
}

function Text2() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[22px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[15px] not-italic relative shrink-0 text-[#34c759] text-[10px] whitespace-nowrap">+5</p>
    </div>
  );
}

function Frame3() {
  return (
    <div className="content-stretch flex gap-[8px] items-center relative shrink-0 w-[269px]">
      <Container2 />
      <Text1 />
      <Text2 />
    </div>
  );
}

function Frame2() {
  return (
    <div className="content-stretch flex items-center relative shrink-0 w-[236px]">
      <Frame3 />
    </div>
  );
}

function Container1() {
  return (
    <div className="content-stretch flex gap-[8px] items-center relative shrink-0" data-name="Container">
      <Text />
      <Frame2 />
    </div>
  );
}

function Text3() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[72px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">AI 应用能力</p>
    </div>
  );
}

function Container6() {
  return <div className="h-[5px] relative rounded-[39856500px] shrink-0 w-[133px]" style={{ backgroundImage: "linear-gradient(177.84703721089954deg, rgb(202, 219, 143) 0%, rgb(162, 216, 76) 100%)" }} data-name="Container" />;
}

function Container5() {
  return (
    <div className="bg-[rgba(79,126,245,0.1)] content-stretch flex flex-[176_0_0] flex-col h-[5px] items-start min-w-px overflow-clip relative rounded-[39856500px]" data-name="Container">
      <Container6 />
    </div>
  );
}

function Text4() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[22px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[16.5px] not-italic relative shrink-0 text-[#111827] text-[11px] text-right whitespace-nowrap">76</p>
    </div>
  );
}

function Text5() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[22px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[15px] not-italic relative shrink-0 text-[#34c759] text-[10px] whitespace-nowrap">+8</p>
    </div>
  );
}

function Container4() {
  return (
    <div className="content-stretch flex gap-[8px] h-[25px] items-center pt-[8px] relative shrink-0 w-full" data-name="Container">
      <Text3 />
      <Container5 />
      <Text4 />
      <Text5 />
    </div>
  );
}

function Text6() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[72px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">用户研究</p>
    </div>
  );
}

function Container9() {
  return <div className="h-[5px] relative rounded-[39856500px] shrink-0 w-[137px]" style={{ backgroundImage: "linear-gradient(177.90984084628934deg, rgb(202, 219, 143) 0%, rgb(162, 216, 76) 100%)" }} data-name="Container" />;
}

function Container8() {
  return (
    <div className="bg-[rgba(79,126,245,0.1)] content-stretch flex flex-[176_0_0] flex-col h-[5px] items-start min-w-px overflow-clip relative rounded-[39856500px]" data-name="Container">
      <Container9 />
    </div>
  );
}

function Text7() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[22px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[16.5px] not-italic relative shrink-0 text-[#111827] text-[11px] text-right whitespace-nowrap">78</p>
    </div>
  );
}

function Text8() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[22px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[15px] not-italic relative shrink-0 text-[#34c759] text-[10px] whitespace-nowrap">+3</p>
    </div>
  );
}

function Container7() {
  return (
    <div className="content-stretch flex gap-[8px] h-[25px] items-center pt-[8px] relative shrink-0 w-full" data-name="Container">
      <Text6 />
      <Container8 />
      <Text7 />
      <Text8 />
    </div>
  );
}

function Frame1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[349px]">
      <Container1 />
      <Container4 />
      <Container7 />
    </div>
  );
}

function ProfilePage() {
  return (
    <div className="content-stretch flex flex-col h-[79px] items-start pt-[12px] relative shrink-0 w-[316px]" data-name="ProfilePage">
      <Frame1 />
    </div>
  );
}

function Clock4() {
  return (
    <div className="relative shrink-0 size-[12px]" data-name="clock">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 12 12" width="12">
        <g clipPath="url(#clip0_0_32)" id="clock">
          <path d={svgPaths.pd1f6ec0} id="Vector" stroke="#1E1F22" strokeLinecap="round" strokeOpacity="0.6" strokeWidth="2" />
        </g>
        <defs>
          <clipPath id="clip0_0_32">
            <rect fill="white" height="12" width="12" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function IconClock4() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center overflow-clip relative shrink-0 size-[14px]" data-name="icon-clock">
      <Clock4 />
    </div>
  );
}

function TimeInfo4() {
  return (
    <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-name="Time Info">
      <IconClock4 />
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">5 个维度 · 综合上升中</p>
    </div>
  );
}

function PriorityBadge4() {
  return (
    <div className="bg-[#373b4d] content-stretch flex items-start px-[12px] py-[6px] relative rounded-[12px] shrink-0" data-name="Priority Badge">
      <div aria-hidden className="absolute border border-solid border-white inset-0 pointer-events-none rounded-[12px]" />
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[12px] text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        查看全部
      </p>
    </div>
  );
}

function BottomRow4() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full" data-name="Bottom Row">
      <TimeInfo4 />
      <PriorityBadge4 />
    </div>
  );
}

function LightCard() {
  return (
    <div className="bg-[#f1f2f6] content-stretch flex flex-col gap-[16px] items-start pb-[20px] pt-[28px] px-[20px] relative rounded-[24px] shrink-0 w-full" data-name="Light Card">
      <TopRow4 />
      <ProgressContainer />
      <ProfilePage />
      <BottomRow4 />
    </div>
  );
}

function Frame() {
  return (
    <div className="content-stretch flex flex-col gap-[16px] items-start relative shrink-0 w-full">
      <TaskGroup />
      <LimeCard />
      <Container />
      <LimeCard1 />
      <LightCard />
    </div>
  );
}

function Container12() {
  return <div className="absolute bg-[rgba(255,255,255,0.18)] border-[1.217px] border-[rgba(255,255,255,0.35)] border-solid h-[64.404px] left-[-0.99px] rounded-[31px] top-[-0.99px] w-[236.346px]" data-name="Container" />;
}

function IconHome() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="IconHome">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="IconHome">
          <path d={svgPaths.p15f7f580} id="Vector" stroke="#7B7979" strokeLinejoin="round" strokeWidth="1.55791" />
        </g>
      </svg>
    </div>
  );
}

function Button() {
  return (
    <div className="content-stretch flex h-[49.995px] items-center justify-center relative rounded-[22px] shrink-0 w-[71.989px]" data-name="Button">
      <IconHome />
    </div>
  );
}

function IconChart() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="IconChart">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="IconChart">
          <path d={svgPaths.p264d8d00} fill="#7B7979" id="Vector" />
          <path d={svgPaths.p3374c200} fill="#7B7979" id="Vector_2" />
          <path d={svgPaths.p2e91c100} fill="#7B7979" id="Vector_3" />
        </g>
      </svg>
    </div>
  );
}

function Button1() {
  return (
    <div className="content-stretch flex h-[50px] items-center justify-center relative rounded-[22px] shrink-0 w-[72px]" data-name="Button">
      <IconChart />
    </div>
  );
}

function IconUser() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="IconUser">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="IconUser">
          <path d={svgPaths.p35d3c040} id="Vector" stroke="#7B7979" strokeWidth="1.55791" />
          <path d={svgPaths.p36c37e00} id="Vector_2" stroke="#7B7979" strokeLinecap="round" strokeWidth="1.55791" />
        </g>
      </svg>
    </div>
  );
}

function Button2() {
  return (
    <div className="content-stretch flex h-[50px] items-center justify-center relative rounded-[22px] shrink-0 w-[72px]" data-name="Button">
      <IconUser />
    </div>
  );
}

function Container13() {
  return (
    <div className="absolute content-stretch flex gap-[2px] items-center left-0 px-[6px] py-[5px] rounded-[30px] top-0" data-name="Container">
      <div aria-hidden className="absolute backdrop-blur-[10px] bg-[rgba(255,255,255,0.04)] inset-0 pointer-events-none rounded-[30px]" />
      <div aria-hidden className="absolute border-[1.217px] border-[rgba(255,255,255,0.3)] border-solid inset-0 pointer-events-none rounded-[30px] shadow-[0px_6px_24px_0px_rgba(0,0,0,0.08),0px_1px_4px_0px_rgba(0,0,0,0.04)]" />
      <Button />
      <Button1 />
      <Button2 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.62),inset_0px_-1px_0px_0px_rgba(255,255,255,0.12),inset_1px_0px_0px_0px_rgba(255,255,255,0.18),inset_-1px_0px_0px_0px_rgba(255,255,255,0.1)]" />
    </div>
  );
}

function Container11() {
  return (
    <div className="h-[62.427px] relative rounded-[30px] shrink-0 w-[234.369px]" data-name="Container">
      <Container12 />
      <Container13 />
    </div>
  );
}

function Text9() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Regular','Noto_Sans:Regular','Noto_Sans_Math:Regular','Noto_Sans_Symbols:Regular','Noto_Sans_Symbols2:Regular',sans-serif] font-normal leading-[24px] relative shrink-0 text-[22px] text-center text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        ✦
      </p>
    </div>
  );
}

function Text10() {
  return (
    <div className="content-stretch flex flex-col items-center pt-[2px] relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[13.5px] relative shrink-0 text-[9px] text-[rgba(255,255,255,0.92)] text-center whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        AI
      </p>
    </div>
  );
}

function Button3() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center relative rounded-[99px] shrink-0 size-[62px]" data-name="Button">
      <div aria-hidden className="absolute backdrop-blur-[10px] inset-0 pointer-events-none rounded-[99px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(79, 126, 245, 0.72) 0%, rgba(167, 123, 230, 0.72) 100%)" }} />
      <div aria-hidden className="absolute border-[1.217px] border-[rgba(255,255,255,0.42)] border-solid inset-0 pointer-events-none rounded-[99px] shadow-[0px_8px_24px_0px_rgba(79,126,245,0.3),0px_2px_6px_0px_rgba(0,0,0,0.06)]" />
      <Text9 />
      <Text10 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.5),inset_0px_-1px_0px_0px_rgba(79,126,245,0.2)]" />
    </div>
  );
}

function Container10() {
  return (
    <div className="absolute content-stretch flex gap-[10px] items-center justify-center left-[25px] pb-[20px] pt-[8px] top-[668px] w-[390px]" data-name="Container">
      <Container11 />
      <Button3 />
    </div>
  );
}

function ScrollContent() {
  return (
    <div className="absolute content-stretch flex flex-col gap-[16px] h-[791px] items-start left-0 overflow-clip px-[20px] right-0 top-[129px]" data-name="Scroll Content">
      <Frame />
      <Container10 />
    </div>
  );
}

function IPhone1314Pro() {
  return (
    <div className="bg-[#f4f5fc] flex-[1_0_0] h-[920px] min-h-[844px] min-w-px overflow-clip relative rounded-[40px] shadow-[0px_12px_24px_0px_rgba(0,0,0,0.1)]" data-name="iPhone 13 / 14 Pro">
      <StatusBar />
      <Header />
      <ScrollContent />
    </div>
  );
}

export default function TaskManagementScreen() {
  return (
    <div className="bg-[#e1e5ed] content-stretch flex items-start pb-[40px] pl-px relative size-full" data-name="task-management-screen">
      <IPhone1314Pro />
    </div>
  );
}