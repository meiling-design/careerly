import { imgFfffff50 } from "./svg-shgx9";
import svgPaths from "./svg-f1zcdsksbz";
type TabBarIPadProps = {
  className?: string;
  children?: React.ReactNode | null;
  showSearch?: boolean;
  showSidebar?: boolean;
};

function TabBarIPad({ className, children = null, showSearch = true, showSidebar = true }: TabBarIPadProps) {
  return (
    <div className={className || "relative"} data-name="Tab Bar - iPad">
      <div className="content-stretch flex items-start p-[4px] relative size-full">
        <div className="absolute inset-0 rounded-[1000px] shadow-[1.25px_0px_0px_-0.75px_#d0d0d0,-1.25px_0px_0px_-0.75px_#d0d0d0,0px_0px_0px_0.5px_#e8e8e8,0px_8px_15px_0px_rgba(0,0,0,0.02)]" data-name="Fill + Shadow">
          <div aria-hidden className="absolute inset-0 pointer-events-none rounded-[1000px]">
            <div className="absolute inset-0 rounded-[1000px]" style={{ backgroundImage: "linear-gradient(90deg, rgba(255, 255, 255, 0.25) 0%, rgba(255, 255, 255, 0.25) 100%), linear-gradient(90deg, rgba(0, 0, 0, 0.25) 0%, rgba(0, 0, 0, 0.25) 100%)" }} />
            <div className="absolute bg-[rgba(68,68,68,0.6)] inset-0 mix-blend-plus-lighter rounded-[1000px]" />
            <div className="absolute bg-[rgba(248,248,248,0.2)] inset-0 mix-blend-luminosity rounded-[1000px]" />
          </div>
        </div>
        <div className="absolute inset-0 pointer-events-none rounded-[1000px]" data-name="Glass Effect">
          <div aria-hidden className="absolute bg-[rgba(0,0,0,0)] inset-0 rounded-[1000px]" />
          <div className="absolute inset-0 rounded-[inherit] shadow-[inset_0px_40px_10px_-40px_#282828,inset_0px_-40px_10px_-40px_#282828,inset_0px_40px_30px_-40px_#e6e6e6]" />
        </div>
        {showSidebar && (
          <div className="relative shrink-0 w-[54px]" data-name="Sidebar">
            <div className="flex flex-row items-center justify-center size-full">
              <div className="content-stretch flex items-center justify-center px-[16px] py-[8px] relative size-full">
                <div className="[word-break:break-word] flex flex-col font-['SF_Pro:Medium',sans-serif] font-[510] justify-center leading-[0] relative shrink-0 text-[#1a1a1a] text-[15px] text-center tracking-[-0.23px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
                  <p className="leading-[20px]">{`\u{100C31}`}</p>
                </div>
              </div>
            </div>
          </div>
        )}
        <div className="content-stretch flex h-[36px] items-center justify-center relative shrink-0" data-name="Buttons">
          {children || (
            <>
              <div className="relative rounded-[100px] shrink-0" data-name="Tab">
                <div className="flex flex-row items-center justify-center size-full">
                  <div className="content-stretch flex gap-[10px] items-center justify-center px-[18px] py-[8px] relative size-full">
                    <div className="absolute bg-[#ededed] inset-0 rounded-[100px]" data-name="Selection" />
                    <div className="content-stretch flex gap-[10px] items-center justify-center relative shrink-0" data-name="Frame">
                      <div className="absolute bg-[rgba(255,255,255,0.5)] inset-[-8px_-18px] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[19.749px_11.853px] mask-size-[37.642px_11.316px]" style={{ maskImage: `url("${imgFfffff50}")` }} data-name="FFFFFF @50%" />
                      <div className="absolute bg-[#08f] inset-[-8px_-18px] mask-alpha mask-intersect mask-no-clip mask-no-repeat mask-position-[19.749px_11.853px] mask-size-[37.642px_11.316px]" style={{ maskImage: `url("${imgFfffff50}")` }} data-name="Tint (Plus D)" />
                    </div>
                  </div>
                </div>
              </div>
              <div className="relative shrink-0" data-name="Tab">
                <div className="flex flex-row items-center justify-center size-full">
                  <div className="content-stretch flex items-center justify-center px-[18px] py-[8px] relative size-full">
                    <div className="[word-break:break-word] flex flex-col font-['SF_Pro:Medium',sans-serif] font-[510] justify-center leading-[0] overflow-hidden relative shrink-0 text-[#1a1a1a] text-[15px] text-center text-ellipsis tracking-[-0.23px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
                      <p className="leading-[20px] overflow-hidden text-ellipsis">Tab 2</p>
                    </div>
                  </div>
                </div>
              </div>
              <div className="relative shrink-0" data-name="Tab">
                <div className="flex flex-row items-center justify-center size-full">
                  <div className="content-stretch flex items-center justify-center px-[18px] py-[8px] relative size-full">
                    <div className="[word-break:break-word] flex flex-col font-['SF_Pro:Medium',sans-serif] font-[510] justify-center leading-[0] overflow-hidden relative shrink-0 text-[#1a1a1a] text-[15px] text-center text-ellipsis tracking-[-0.23px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
                      <p className="leading-[20px] overflow-hidden text-ellipsis">Tab 3</p>
                    </div>
                  </div>
                </div>
              </div>
              <div className="relative shrink-0" data-name="Tab">
                <div className="flex flex-row items-center justify-center size-full">
                  <div className="content-stretch flex items-center justify-center px-[18px] py-[8px] relative size-full">
                    <div className="[word-break:break-word] flex flex-col font-['SF_Pro:Medium',sans-serif] font-[510] justify-center leading-[0] overflow-hidden relative shrink-0 text-[#1a1a1a] text-[15px] text-center text-ellipsis tracking-[-0.23px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
                      <p className="leading-[20px] overflow-hidden text-ellipsis">Tab 4</p>
                    </div>
                  </div>
                </div>
              </div>
              <div className="relative shrink-0" data-name="Tab">
                <div className="flex flex-row items-center justify-center size-full">
                  <div className="content-stretch flex items-center justify-center px-[18px] py-[8px] relative size-full">
                    <div className="[word-break:break-word] flex flex-col font-['SF_Pro:Medium',sans-serif] font-[510] justify-center leading-[0] overflow-hidden relative shrink-0 text-[#1a1a1a] text-[15px] text-center text-ellipsis tracking-[-0.23px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
                      <p className="leading-[20px] overflow-hidden text-ellipsis">Tab 5</p>
                    </div>
                  </div>
                </div>
              </div>
            </>
          )}
        </div>
        {showSearch && (
          <div className="relative shrink-0 w-[54px]" data-name="Search">
            <div className="flex flex-row items-center justify-center size-full">
              <div className="content-stretch flex items-center justify-center px-[16px] py-[8px] relative size-full">
                <div className="[word-break:break-word] flex flex-col font-['SF_Pro:Medium',sans-serif] font-[510] justify-center leading-[0] relative shrink-0 text-[#1a1a1a] text-[15px] text-center tracking-[-0.23px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
                  <p className="leading-[20px]">{`\u{100C31}`}</p>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function Text() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:SemiBold',sans-serif] font-semibold leading-[19.5px] relative shrink-0 text-[#6b7280] text-[13px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        9:41
      </p>
    </div>
  );
}

function Icon() {
  return (
    <div className="h-[11.995px] relative shrink-0 w-[15.987px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.995" preserveAspectRatio="none" viewBox="0 0 15.987 11.995" width="15.987">
        <g clipPath="url(#clip0_0_43)" id="Icon">
          <path d={svgPaths.p5b1c2f0} fill="#6B7280" id="Vector" />
          <path d={svgPaths.pfa93380} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p2cd646f0} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p10337c00} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_43">
            <rect fill="white" height="11.995" width="15.987" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Icon1() {
  return (
    <div className="h-[11.995px] relative shrink-0 w-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.995" preserveAspectRatio="none" viewBox="0 0 17.983 11.995" width="17.983">
        <g clipPath="url(#clip0_0_50)" id="Icon">
          <path d={svgPaths.p30c54b00} id="Vector" stroke="#6B7280" strokeWidth="0.999056" />
          <path d={svgPaths.p2391db00} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p20ca00c0} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_50">
            <rect fill="white" height="11.995" width="17.983" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container2() {
  return (
    <div className="content-stretch flex gap-[8px] items-center relative shrink-0" data-name="Container">
      <Icon />
      <Icon1 />
    </div>
  );
}

function Container1() {
  return (
    <div className="content-stretch flex items-center justify-between pb-[2px] pt-[12px] px-[24px] relative shrink-0 w-full" data-name="Container">
      <Text />
      <Container2 />
    </div>
  );
}

function PlaceholderForAnalysisHome() {
  return <div className="h-[131px] relative shrink-0 w-full" data-name="Placeholder for AnalysisHome" />;
}

function Paragraph() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[18px] relative shrink-0 text-[#fefefe] text-[12px] whitespace-nowrap">分析</p>
    </div>
  );
}

function Heading() {
  return (
    <div className="content-stretch flex flex-col h-[34px] items-start relative shrink-0 w-full" data-name="Heading 1">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[normal] not-italic relative shrink-0 text-[24px] text-white whitespace-nowrap">职业分析</p>
    </div>
  );
}

function Container5() {
  return (
    <div className="absolute content-stretch flex flex-col h-[814px] items-start left-[0.26px] px-[20px] py-[12px] top-[0.23px] w-[390px]" style={{ backgroundImage: "linear-gradient(90deg, rgba(0, 0, 0, 0.02) 0%, rgba(0, 0, 0, 0.02) 100%), linear-gradient(110.97843122580481deg, rgb(167, 123, 230) 11.492%, rgb(99, 91, 219) 46.146%, rgb(91, 124, 250) 88.517%)" }} data-name="Container">
      <Paragraph />
      <Heading />
      <TabBarIPad className="relative shrink-0 w-[351px]" showSearch={false} showSidebar={false}>
        <div className="relative shrink-0 w-[172px]" data-name="Tab">
          <div className="flex flex-row items-center justify-center size-full">
            <div className="content-stretch flex items-center justify-center px-[18px] py-[8px] relative size-full">
              <div className="[word-break:break-word] flex flex-col font-['SF_Pro:Medium',sans-serif] font-[510] justify-center leading-[0] overflow-hidden relative shrink-0 text-[#bfbfbf] text-[15px] text-center text-ellipsis tracking-[-0.23px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
                <p className="leading-[20px] overflow-hidden text-ellipsis">新建分析</p>
              </div>
            </div>
          </div>
        </div>
        <div className="bg-[#373b4d] content-stretch drop-shadow-[0px_2px_4px_rgba(79,126,245,0.12)] flex flex-col h-[36px] items-center justify-center relative rounded-[100px] shrink-0 w-[170px]" data-name="Button">
          <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[19.5px] relative shrink-0 text-[#f0f4ff] text-[15px] text-center whitespace-nowrap">历史分析</p>
        </div>
      </TabBarIPad>
    </div>
  );
}

function AnalysisHome() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[390px]" data-name="AnalysisHome">
      <PlaceholderForAnalysisHome />
      <Container5 />
    </div>
  );
}

function Frame() {
  return (
    <div className="absolute h-[30px] left-[0.26px] right-[-0.26px] top-[-12.77px]" data-name="Frame">
      <p className="[word-break:break-word] absolute font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[20px] left-[20.26px] not-italic right-[17.74px] text-[14px] text-[rgba(255,255,255,0.8)] top-[1.23px]">记录你与不同目标岗位之间的变化</p>
    </div>
  );
}

function TitleGroup() {
  return (
    <div className="h-[33px] relative shrink-0 w-[390px]" data-name="title-group">
      <Frame />
    </div>
  );
}

function Plus() {
  return (
    <div className="relative shrink-0 size-[16px]" data-name="plus">
      <svg className="absolute block inset-0 size-full" fill="none" height="16" preserveAspectRatio="none" viewBox="0 0 16 16" width="16">
        <g id="plus">
          <path d={svgPaths.p1529f7e0} id="Vector" stroke="#1A2D2A" strokeLinecap="round" strokeWidth="2" />
        </g>
      </svg>
    </div>
  );
}

function PlusIcon() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center overflow-clip relative shrink-0 size-[16px]" data-name="plus-icon">
      <Plus />
    </div>
  );
}

function ActionPlusBtn() {
  return (
    <div className="bg-white content-stretch drop-shadow-[0px_4px_6px_rgba(0,0,0,0.06)] flex items-center justify-center relative rounded-[22px] shrink-0 size-[40px]" data-name="action-plus-btn">
      <PlusIcon />
    </div>
  );
}

function Frame6() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[normal] not-italic relative shrink-0 text-[22px] text-white w-[220px]">一次分析 · 10 个岗位</p>
      <ActionPlusBtn />
    </div>
  );
}

function Clock() {
  return (
    <div className="relative shrink-0 size-[12px]" data-name="clock">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 12 12" width="12">
        <g clipPath="url(#clip0_0_48)" id="clock">
          <path d={svgPaths.pd1f6ec0} id="Vector" stroke="white" strokeLinecap="round" strokeOpacity="0.6" strokeWidth="2" />
        </g>
        <defs>
          <clipPath id="clip0_0_48">
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
      <p className="[word-break:break-word] font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0 text-[12px] text-[rgba(255,255,255,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>{` 2026/9/7`}</p>
    </div>
  );
}

function PriorityBadge() {
  return (
    <div className="bg-[rgba(255,255,255,0.62)] border border-solid border-white content-stretch flex items-center justify-center px-[12px] py-[6px] relative rounded-[12px] shrink-0" data-name="Priority Badge">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[12px] text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        查看分析
      </p>
    </div>
  );
}

function Frame4() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full">
      <TimeInfo />
      <PriorityBadge />
    </div>
  );
}

function Frame7() {
  return (
    <div className="content-stretch flex flex-col gap-[74px] items-end relative shrink-0 w-[343px]">
      <Frame6 />
      <Frame4 />
    </div>
  );
}

function TextColumn() {
  return <div className="absolute h-px left-0 top-[207.5px] w-[180px]" data-name="text-column" />;
}

function Text1() {
  return (
    <div className="content-stretch flex flex-[184_0_0] flex-col items-start min-w-px relative" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[0] not-italic relative shrink-0 text-[12px] text-white whitespace-nowrap">
        <span className="font-['Roboto:Medium',sans-serif] leading-[18px]" style={{ fontVariationSettings: '"wdth" 100' }}>{`AI `}</span>
        <span className="font-['Noto_Sans_SC:Medium',sans-serif] leading-[18px]">产品经理</span>
      </p>
    </div>
  );
}

function Container8() {
  return <div className="border border-[#f9f9f9] border-solid h-[6px] relative rounded-[40822700px] shrink-0 w-[69px]" style={{ backgroundImage: "linear-gradient(175.21610292318303deg, rgb(192, 217, 255) 1.7867%, rgb(220, 233, 251) 39.555%, rgb(229, 220, 250) 100%)" }} data-name="Container" />;
}

function Container7() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[6px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-[80px]" data-name="Container">
      <Container8 />
    </div>
  );
}

function Text2() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[36px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[18px] relative shrink-0 text-[12px] text-right text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        86%
      </p>
    </div>
  );
}

function Container6() {
  return (
    <div className="content-stretch flex gap-[8px] h-[18px] items-center relative shrink-0 w-full" data-name="Container">
      <Text1 />
      <Container7 />
      <Text2 />
    </div>
  );
}

function Text3() {
  return (
    <div className="content-stretch flex flex-[184_0_0] flex-col items-start min-w-px relative" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[12px] text-white whitespace-nowrap">产品经理</p>
    </div>
  );
}

function Container11() {
  return <div className="h-[6px] relative rounded-[40822700px] shrink-0 w-[66px]" style={{ backgroundImage: "linear-gradient(174.8055710922652deg, rgb(220, 233, 251) 0%, rgb(220, 233, 251) 38.462%, rgb(251, 233, 241) 100%)" }} data-name="Container" />;
}

function Container10() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[6px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-[80px]" data-name="Container">
      <Container11 />
    </div>
  );
}

function Text4() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[36px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[18px] relative shrink-0 text-[12px] text-right text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        82%
      </p>
    </div>
  );
}

function Container9() {
  return (
    <div className="content-stretch flex gap-[8px] h-[22px] items-center pt-[8px] relative shrink-0 w-full" data-name="Container">
      <Text3 />
      <Container10 />
      <Text4 />
    </div>
  );
}

function Text5() {
  return (
    <div className="content-stretch flex flex-[184_0_0] flex-col items-start min-w-px relative" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:DemiLight',sans-serif] font-[350] leading-[18px] relative shrink-0 text-[12px] text-white whitespace-nowrap">数据产品经理</p>
    </div>
  );
}

function Container14() {
  return <div className="h-[6px] relative rounded-[40822700px] shrink-0 w-[59px]" style={{ backgroundImage: "linear-gradient(174.19327309446842deg, rgb(220, 233, 251) 0%, rgb(220, 233, 251) 38.462%, rgb(251, 233, 241) 100%)" }} data-name="Container" />;
}

function Container13() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[6px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-[80px]" data-name="Container">
      <Container14 />
    </div>
  );
}

function Text6() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[36px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[18px] relative shrink-0 text-[12px] text-right text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        74%
      </p>
    </div>
  );
}

function Container12() {
  return (
    <div className="content-stretch flex gap-[8px] h-[26px] items-center pt-[8px] relative shrink-0 w-full" data-name="Container">
      <Text5 />
      <Container13 />
      <Text6 />
    </div>
  );
}

function Frame5() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 top-[12px] w-[316px]">
      <Container6 />
      <Container9 />
      <Container12 />
    </div>
  );
}

function AnalysisHome1() {
  return (
    <div className="absolute h-[26.5px] left-0 top-0 w-[180px]" data-name="AnalysisHome">
      <Frame5 />
    </div>
  );
}

function BottomRow() {
  return <div className="absolute h-[14px] left-0 top-[104px] w-[180px]" data-name="Bottom Row" />;
}

function Frame1() {
  return (
    <div className="absolute h-[78px] left-[14.26px] top-[41.23px] w-[360px]">
      <TextColumn />
      <AnalysisHome1 />
      <BottomRow />
    </div>
  );
}

function FrostedOptionCard() {
  return (
    <div className="backdrop-blur-[12px] bg-[rgba(255,255,255,0.09)] border border-[rgba(255,255,255,0.2)] border-solid content-stretch flex flex-col gap-[10px] items-start px-[10px] py-[11px] relative rounded-[28px] shrink-0 w-full" data-name="frosted-option-card">
      <Frame7 />
      <Frame1 />
    </div>
  );
}

function Plus1() {
  return (
    <div className="relative shrink-0 size-[16px]" data-name="plus">
      <svg className="absolute block inset-0 size-full" fill="none" height="16" preserveAspectRatio="none" viewBox="0 0 16 16" width="16">
        <g id="plus">
          <path d={svgPaths.p1529f7e0} id="Vector" stroke="#1A2D2A" strokeLinecap="round" strokeWidth="2" />
        </g>
      </svg>
    </div>
  );
}

function PlusIcon1() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center overflow-clip relative shrink-0 size-[16px]" data-name="plus-icon">
      <Plus1 />
    </div>
  );
}

function ActionPlusBtn1() {
  return (
    <div className="bg-white content-stretch drop-shadow-[0px_4px_6px_rgba(0,0,0,0.06)] flex items-center justify-center relative rounded-[22px] shrink-0 size-[40px]" data-name="action-plus-btn">
      <PlusIcon1 />
    </div>
  );
}

function Frame12() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[normal] not-italic relative shrink-0 text-[22px] text-white w-[220px]">一次分析 · 3 个岗位</p>
      <ActionPlusBtn1 />
    </div>
  );
}

function Clock1() {
  return (
    <div className="relative shrink-0 size-[12px]" data-name="clock">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 12 12" width="12">
        <g clipPath="url(#clip0_0_48)" id="clock">
          <path d={svgPaths.pd1f6ec0} id="Vector" stroke="white" strokeLinecap="round" strokeOpacity="0.6" strokeWidth="2" />
        </g>
        <defs>
          <clipPath id="clip0_0_48">
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
      <p className="[word-break:break-word] font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0 text-[12px] text-[rgba(255,255,255,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>{` 2026/9/7`}</p>
    </div>
  );
}

function PriorityBadge1() {
  return (
    <div className="bg-[rgba(255,255,255,0.62)] border border-solid border-white content-stretch flex items-center justify-center px-[12px] py-[6px] relative rounded-[12px] shrink-0" data-name="Priority Badge">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[12px] text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        查看分析
      </p>
    </div>
  );
}

function Frame13() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full">
      <TimeInfo1 />
      <PriorityBadge1 />
    </div>
  );
}

function Frame11() {
  return (
    <div className="content-stretch flex flex-col gap-[74px] items-end relative shrink-0 w-[343px]">
      <Frame12 />
      <Frame13 />
    </div>
  );
}

function TextColumn1() {
  return <div className="absolute h-px left-0 top-[207.5px] w-[180px]" data-name="text-column" />;
}

function Text7() {
  return (
    <div className="content-stretch flex flex-[184_0_0] flex-col items-start min-w-px relative" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[0] not-italic relative shrink-0 text-[12px] text-white whitespace-nowrap">
        <span className="font-['Roboto:Medium',sans-serif] leading-[18px]" style={{ fontVariationSettings: '"wdth" 100' }}>{`AI `}</span>
        <span className="font-['Noto_Sans_SC:Medium',sans-serif] leading-[18px]">产品经理</span>
      </p>
    </div>
  );
}

function Container17() {
  return <div className="border border-[#f9f9f9] border-solid h-[6px] relative rounded-[40822700px] shrink-0 w-[69px]" style={{ backgroundImage: "linear-gradient(175.21610292318303deg, rgb(192, 217, 255) 1.7867%, rgb(220, 233, 251) 39.555%, rgb(229, 220, 250) 100%)" }} data-name="Container" />;
}

function Container16() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[6px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-[80px]" data-name="Container">
      <Container17 />
    </div>
  );
}

function Text8() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[36px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[18px] relative shrink-0 text-[12px] text-right text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        86%
      </p>
    </div>
  );
}

function Container15() {
  return (
    <div className="content-stretch flex gap-[8px] h-[18px] items-center relative shrink-0 w-full" data-name="Container">
      <Text7 />
      <Container16 />
      <Text8 />
    </div>
  );
}

function Text9() {
  return (
    <div className="content-stretch flex flex-[184_0_0] flex-col items-start min-w-px relative" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[12px] text-white whitespace-nowrap">产品经理</p>
    </div>
  );
}

function Container20() {
  return <div className="h-[6px] relative rounded-[40822700px] shrink-0 w-[66px]" style={{ backgroundImage: "linear-gradient(174.8055710922652deg, rgb(220, 233, 251) 0%, rgb(220, 233, 251) 38.462%, rgb(251, 233, 241) 100%)" }} data-name="Container" />;
}

function Container19() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[6px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-[80px]" data-name="Container">
      <Container20 />
    </div>
  );
}

function Text10() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[36px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[18px] relative shrink-0 text-[12px] text-right text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        82%
      </p>
    </div>
  );
}

function Container18() {
  return (
    <div className="content-stretch flex gap-[8px] h-[22px] items-center pt-[8px] relative shrink-0 w-full" data-name="Container">
      <Text9 />
      <Container19 />
      <Text10 />
    </div>
  );
}

function Text11() {
  return (
    <div className="content-stretch flex flex-[184_0_0] flex-col items-start min-w-px relative" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:DemiLight',sans-serif] font-[350] leading-[18px] relative shrink-0 text-[12px] text-white whitespace-nowrap">数据产品经理</p>
    </div>
  );
}

function Container23() {
  return <div className="h-[6px] relative rounded-[40822700px] shrink-0 w-[59px]" style={{ backgroundImage: "linear-gradient(174.19327309446842deg, rgb(220, 233, 251) 0%, rgb(220, 233, 251) 38.462%, rgb(251, 233, 241) 100%)" }} data-name="Container" />;
}

function Container22() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[6px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-[80px]" data-name="Container">
      <Container23 />
    </div>
  );
}

function Text12() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[36px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[18px] relative shrink-0 text-[12px] text-right text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        74%
      </p>
    </div>
  );
}

function Container21() {
  return (
    <div className="content-stretch flex gap-[8px] h-[26px] items-center pt-[8px] relative shrink-0 w-full" data-name="Container">
      <Text11 />
      <Container22 />
      <Text12 />
    </div>
  );
}

function Frame14() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 top-[12px] w-[316px]">
      <Container15 />
      <Container18 />
      <Container21 />
    </div>
  );
}

function AnalysisHome2() {
  return (
    <div className="absolute h-[26.5px] left-0 top-0 w-[180px]" data-name="AnalysisHome">
      <Frame14 />
    </div>
  );
}

function BottomRow1() {
  return <div className="absolute h-[14px] left-0 top-[104px] w-[180px]" data-name="Bottom Row" />;
}

function Frame2() {
  return (
    <div className="absolute h-[78px] left-[14.26px] top-[41.23px] w-[360px]">
      <TextColumn1 />
      <AnalysisHome2 />
      <BottomRow1 />
    </div>
  );
}

function FrostedOptionCard1() {
  return (
    <div className="backdrop-blur-[12px] bg-[rgba(255,255,255,0.09)] border border-[rgba(255,255,255,0.2)] border-solid content-stretch flex flex-col gap-[10px] items-start px-[10px] py-[11px] relative rounded-[28px] shrink-0 w-full" data-name="frosted-option-card">
      <Frame11 />
      <Frame2 />
    </div>
  );
}

function Plus2() {
  return (
    <div className="relative shrink-0 size-[16px]" data-name="plus">
      <svg className="absolute block inset-0 size-full" fill="none" height="16" preserveAspectRatio="none" viewBox="0 0 16 16" width="16">
        <g id="plus">
          <path d={svgPaths.p1529f7e0} id="Vector" stroke="#1A2D2A" strokeLinecap="round" strokeWidth="2" />
        </g>
      </svg>
    </div>
  );
}

function PlusIcon2() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center overflow-clip relative shrink-0 size-[16px]" data-name="plus-icon">
      <Plus2 />
    </div>
  );
}

function ActionPlusBtn2() {
  return (
    <div className="bg-white content-stretch drop-shadow-[0px_4px_6px_rgba(0,0,0,0.06)] flex items-center justify-center relative rounded-[22px] shrink-0 size-[40px]" data-name="action-plus-btn">
      <PlusIcon2 />
    </div>
  );
}

function Frame16() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[normal] not-italic relative shrink-0 text-[22px] text-white w-[220px]">一次分析 · 3 个岗位</p>
      <ActionPlusBtn2 />
    </div>
  );
}

function Clock2() {
  return (
    <div className="relative shrink-0 size-[12px]" data-name="clock">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 12 12" width="12">
        <g clipPath="url(#clip0_0_48)" id="clock">
          <path d={svgPaths.pd1f6ec0} id="Vector" stroke="white" strokeLinecap="round" strokeOpacity="0.6" strokeWidth="2" />
        </g>
        <defs>
          <clipPath id="clip0_0_48">
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
      <p className="[word-break:break-word] font-['Roboto:Regular',sans-serif] font-normal leading-[normal] relative shrink-0 text-[12px] text-[rgba(255,255,255,0.6)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>{` 2026/9/7`}</p>
    </div>
  );
}

function PriorityBadge2() {
  return (
    <div className="bg-[rgba(255,255,255,0.62)] border border-solid border-white content-stretch flex items-center justify-center px-[12px] py-[6px] relative rounded-[12px] shrink-0" data-name="Priority Badge">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[normal] relative shrink-0 text-[12px] text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        查看分析
      </p>
    </div>
  );
}

function Frame17() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-full">
      <TimeInfo2 />
      <PriorityBadge2 />
    </div>
  );
}

function Frame15() {
  return (
    <div className="content-stretch flex flex-col gap-[74px] items-end relative shrink-0 w-[343px]">
      <Frame16 />
      <Frame17 />
    </div>
  );
}

function TextColumn2() {
  return <div className="absolute h-px left-0 top-[207.5px] w-[180px]" data-name="text-column" />;
}

function Text13() {
  return (
    <div className="content-stretch flex flex-[184_0_0] flex-col items-start min-w-px relative" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[0] not-italic relative shrink-0 text-[12px] text-white whitespace-nowrap">
        <span className="font-['Roboto:Medium',sans-serif] leading-[18px]" style={{ fontVariationSettings: '"wdth" 100' }}>{`AI `}</span>
        <span className="font-['Noto_Sans_SC:Medium',sans-serif] leading-[18px]">产品经理</span>
      </p>
    </div>
  );
}

function Container26() {
  return <div className="border border-[#f9f9f9] border-solid h-[6px] relative rounded-[40822700px] shrink-0 w-[69px]" style={{ backgroundImage: "linear-gradient(175.21610292318303deg, rgb(192, 217, 255) 1.7867%, rgb(220, 233, 251) 39.555%, rgb(229, 220, 250) 100%)" }} data-name="Container" />;
}

function Container25() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[6px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-[80px]" data-name="Container">
      <Container26 />
    </div>
  );
}

function Text14() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[36px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[18px] relative shrink-0 text-[12px] text-right text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        86%
      </p>
    </div>
  );
}

function Container24() {
  return (
    <div className="content-stretch flex gap-[8px] h-[18px] items-center relative shrink-0 w-full" data-name="Container">
      <Text13 />
      <Container25 />
      <Text14 />
    </div>
  );
}

function Text15() {
  return (
    <div className="content-stretch flex flex-[184_0_0] flex-col items-start min-w-px relative" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[12px] text-white whitespace-nowrap">产品经理</p>
    </div>
  );
}

function Container29() {
  return <div className="h-[6px] relative rounded-[40822700px] shrink-0 w-[66px]" style={{ backgroundImage: "linear-gradient(174.8055710922652deg, rgb(220, 233, 251) 0%, rgb(220, 233, 251) 38.462%, rgb(251, 233, 241) 100%)" }} data-name="Container" />;
}

function Container28() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[6px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-[80px]" data-name="Container">
      <Container29 />
    </div>
  );
}

function Text16() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[36px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[18px] relative shrink-0 text-[12px] text-right text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        82%
      </p>
    </div>
  );
}

function Container27() {
  return (
    <div className="content-stretch flex gap-[8px] h-[22px] items-center pt-[8px] relative shrink-0 w-full" data-name="Container">
      <Text15 />
      <Container28 />
      <Text16 />
    </div>
  );
}

function Text17() {
  return (
    <div className="content-stretch flex flex-[184_0_0] flex-col items-start min-w-px relative" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:DemiLight',sans-serif] font-[350] leading-[18px] relative shrink-0 text-[12px] text-white whitespace-nowrap">数据产品经理</p>
    </div>
  );
}

function Container32() {
  return <div className="h-[6px] relative rounded-[40822700px] shrink-0 w-[59px]" style={{ backgroundImage: "linear-gradient(174.19327309446842deg, rgb(220, 233, 251) 0%, rgb(220, 233, 251) 38.462%, rgb(251, 233, 241) 100%)" }} data-name="Container" />;
}

function Container31() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[6px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-[80px]" data-name="Container">
      <Container32 />
    </div>
  );
}

function Text18() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-[36px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[18px] relative shrink-0 text-[12px] text-right text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        74%
      </p>
    </div>
  );
}

function Container30() {
  return (
    <div className="content-stretch flex gap-[8px] h-[26px] items-center pt-[8px] relative shrink-0 w-full" data-name="Container">
      <Text17 />
      <Container31 />
      <Text18 />
    </div>
  );
}

function Frame18() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 top-[12px] w-[316px]">
      <Container24 />
      <Container27 />
      <Container30 />
    </div>
  );
}

function AnalysisHome3() {
  return (
    <div className="absolute h-[26.5px] left-0 top-0 w-[180px]" data-name="AnalysisHome">
      <Frame18 />
    </div>
  );
}

function BottomRow2() {
  return <div className="absolute h-[14px] left-0 top-[104px] w-[180px]" data-name="Bottom Row" />;
}

function Frame3() {
  return (
    <div className="absolute h-[78px] left-[14.26px] top-[41.23px] w-[360px]">
      <TextColumn2 />
      <AnalysisHome3 />
      <BottomRow2 />
    </div>
  );
}

function FrostedOptionCard2() {
  return (
    <div className="backdrop-blur-[12px] bg-[rgba(255,255,255,0.09)] border border-[rgba(255,255,255,0.2)] border-solid content-stretch flex flex-col gap-[10px] items-start px-[10px] py-[11px] relative rounded-[28px] shrink-0 w-full" data-name="frosted-option-card">
      <Frame15 />
      <Frame3 />
    </div>
  );
}

function Frame10() {
  return (
    <div className="content-stretch flex flex-col gap-[16px] items-start relative shrink-0 w-full">
      <FrostedOptionCard />
      <FrostedOptionCard1 />
      <FrostedOptionCard2 />
    </div>
  );
}

function Frame8() {
  return (
    <div className="absolute content-stretch flex flex-col h-[415px] items-start left-0 right-0 top-0">
      <Frame10 />
    </div>
  );
}

function Frame9() {
  return (
    <div className="-translate-x-1/2 absolute h-[452px] left-[calc(50%+0.26px)] top-[148.23px] w-[364px]">
      <Frame8 />
    </div>
  );
}

function Container4() {
  return (
    <div className="bg-[#1d1e2d] content-stretch flex flex-col h-[810px] items-start overflow-clip pb-[96px] relative shrink-0" data-name="Container">
      <AnalysisHome />
      <TitleGroup />
      <Frame9 />
    </div>
  );
}

function Container3() {
  return (
    <div className="content-stretch flex flex-[810.491_0_0] flex-col items-start min-h-px overflow-clip relative w-full" data-name="Container">
      <Container4 />
    </div>
  );
}

function Container35() {
  return <div className="absolute bg-[rgba(255,255,255,0.18)] border-[1.217px] border-[rgba(255,255,255,0.35)] border-solid h-[64.404px] left-[-0.99px] rounded-[31px] top-[-0.99px] w-[236.346px]" data-name="Container" />;
}

function Container37() {
  return (
    <div className="absolute h-[49.995px] left-[81.21px] pointer-events-none rounded-[22px] top-[6.22px] w-[71.989px]" data-name="Container">
      <div aria-hidden className="absolute backdrop-blur-[6px] bg-[rgba(255,255,255,0.5)] inset-0 rounded-[22px]" />
      <div aria-hidden className="absolute border-[1.217px] border-[rgba(255,255,255,0.4)] border-solid inset-0 rounded-[22px] shadow-[0px_1px_6px_0px_rgba(0,0,0,0.07)]" />
      <div className="absolute inset-0 rounded-[inherit] shadow-[inset_0px_1px_0px_0px_rgba(255,255,255,0.55)]" />
    </div>
  );
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
    <div className="absolute content-stretch flex h-[49.995px] items-center justify-center left-[7.2px] rounded-[22px] top-[6.22px] w-[71.989px]" data-name="Button">
      <IconHome />
    </div>
  );
}

function IconChart() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="IconChart">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="IconChart">
          <path d={svgPaths.p264d8d00} fill="url(#paint0_linear_0_36)" id="Vector" />
          <path d={svgPaths.p3374c200} fill="url(#paint1_linear_0_36)" id="Vector_2" />
          <path d={svgPaths.p2e91c100} fill="url(#paint2_linear_0_36)" id="Vector_3" />
        </g>
        <defs>
          <linearGradient gradientUnits="userSpaceOnUse" id="paint0_linear_0_36" x1="2.74925" x2="19.2447" y1="3.66567" y2="19.2447">
            <stop stopColor="#4F7EF5" />
            <stop offset="1" stopColor="#A77BE6" />
          </linearGradient>
          <linearGradient gradientUnits="userSpaceOnUse" id="paint1_linear_0_36" x1="2.74925" x2="19.2447" y1="3.66567" y2="19.2448">
            <stop stopColor="#4F7EF5" />
            <stop offset="1" stopColor="#A77BE6" />
          </linearGradient>
          <linearGradient gradientUnits="userSpaceOnUse" id="paint2_linear_0_36" x1="2.74925" x2="19.2447" y1="3.66567" y2="19.2447">
            <stop stopColor="#4F7EF5" />
            <stop offset="1" stopColor="#A77BE6" />
          </linearGradient>
        </defs>
      </svg>
    </div>
  );
}

function Button1() {
  return (
    <div className="absolute content-stretch flex h-[50px] items-center justify-center left-[81.18px] rounded-[22px] top-[6.21px] w-[72px]" data-name="Button">
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
    <div className="absolute content-stretch flex h-[50px] items-center justify-center left-[155.17px] rounded-[22px] top-[6.21px] w-[72px]" data-name="Button">
      <IconUser />
    </div>
  );
}

function Container36() {
  return (
    <div className="absolute h-[62.427px] left-0 rounded-[30px] top-0 w-[234.369px]" data-name="Container">
      <div aria-hidden className="absolute backdrop-blur-[10px] bg-[rgba(255,255,255,0.04)] inset-0 pointer-events-none rounded-[30px]" />
      <div aria-hidden className="absolute border-[1.217px] border-[rgba(255,255,255,0.3)] border-solid inset-0 pointer-events-none rounded-[30px] shadow-[0px_6px_24px_0px_rgba(0,0,0,0.08),0px_1px_4px_0px_rgba(0,0,0,0.04)]" />
      <Container37 />
      <Button />
      <Button1 />
      <Button2 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.62),inset_0px_-1px_0px_0px_rgba(255,255,255,0.12),inset_1px_0px_0px_0px_rgba(255,255,255,0.18),inset_-1px_0px_0px_0px_rgba(255,255,255,0.1)]" />
    </div>
  );
}

function Container34() {
  return (
    <div className="h-[62.427px] relative rounded-[30px] shrink-0 w-[234.369px]" data-name="Container">
      <Container35 />
      <Container36 />
    </div>
  );
}

function Text19() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Regular','Noto_Sans:Regular','Noto_Sans_Math:Regular','Noto_Sans_Symbols:Regular','Noto_Sans_Symbols2:Regular',sans-serif] font-normal leading-[24px] relative shrink-0 text-[22px] text-center text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        ✦
      </p>
    </div>
  );
}

function Text20() {
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
    <div className="content-stretch flex flex-col items-center justify-center opacity-88 relative rounded-[99px] shrink-0 size-[62px]" data-name="Button">
      <div aria-hidden className="absolute backdrop-blur-[10px] inset-0 pointer-events-none rounded-[99px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(79, 126, 245, 0.72) 0%, rgba(167, 123, 230, 0.72) 100%)" }} />
      <div aria-hidden className="absolute border-[1.217px] border-[rgba(255,255,255,0.42)] border-solid inset-0 pointer-events-none rounded-[99px] shadow-[0px_8px_24px_0px_rgba(79,126,245,0.3),0px_2px_6px_0px_rgba(0,0,0,0.06)]" />
      <Text19 />
      <Text20 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.5),inset_0px_-1px_0px_0px_rgba(79,126,245,0.2)]" />
    </div>
  );
}

function Container33() {
  return (
    <div className="absolute content-stretch flex gap-[10px] items-center justify-center left-0 pb-[20px] pt-[8px] top-[753.58px] w-[390px]" data-name="Container">
      <Container34 />
      <Button3 />
    </div>
  );
}

function Container() {
  return (
    <div className="absolute content-stretch flex flex-col h-[843.986px] items-start left-[5.74px] max-h-[844px] max-w-[390px] overflow-clip top-[14.77px] w-[390px]" style={{ backgroundImage: "linear-gradient(110.2948550978526deg, rgb(220, 233, 251) 11.492%, rgb(229, 220, 250) 46.146%, rgb(251, 233, 241) 88.517%)" }} data-name="Container">
      <Container1 />
      <Container3 />
      <Container33 />
    </div>
  );
}

function App() {
  return (
    <div className="absolute bg-[#d2def0] h-[873.526px] left-0 top-0 w-[401.481px]" data-name="App">
      <Container />
    </div>
  );
}

export default function CareerlyAppInterfaceDesignCopy() {
  return (
    <div className="bg-white relative size-full" data-name="Careerly App Interface Design (Copy)">
      <App />
    </div>
  );
}