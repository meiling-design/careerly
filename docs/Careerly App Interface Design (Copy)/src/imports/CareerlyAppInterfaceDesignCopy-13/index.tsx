import svgPaths from "./svg-z3z0kpslcr";

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
        <g clipPath="url(#clip0_0_12)" id="Icon">
          <path d={svgPaths.p5b1c2f0} fill="#6B7280" id="Vector" />
          <path d={svgPaths.pfa93380} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p2cd646f0} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p10337c00} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_12">
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
        <g clipPath="url(#clip0_0_8)" id="Icon">
          <path d={svgPaths.p30c54b00} id="Vector" stroke="#6B7280" strokeWidth="0.999056" />
          <path d={svgPaths.p2391db00} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p20ca00c0} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_8">
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

function Check() {
  return (
    <div className="h-[28px] relative shrink-0 w-[39px]" data-name="check">
      <svg className="absolute block inset-0 size-full" fill="none" height="28" preserveAspectRatio="none" viewBox="0 0 39 28" width="39">
        <g id="check">
          <path d="M36 2L13.3125 24L3 14" id="Vector" stroke="white" strokeLinecap="round" strokeWidth="4" />
        </g>
      </svg>
    </div>
  );
}

function IconInnerCircle() {
  return (
    <div className="content-stretch drop-shadow-[0px_8px_10px_rgba(91,124,246,0.25)] flex flex-col items-center justify-center relative rounded-[99px] shrink-0 size-[100px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(91, 124, 246) 0%, rgb(167, 123, 230) 100%)" }} data-name="IconInnerCircle">
      <Check />
    </div>
  );
}

function IconOuterRing() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center relative rounded-[99px] shrink-0 size-[126px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(91, 124, 246, 0.2) 0%, rgba(167, 123, 230, 0.2) 100%)" }} data-name="IconOuterRing">
      <IconInnerCircle />
    </div>
  );
}

function IconSection() {
  return (
    <div className="absolute content-stretch flex flex-col items-center left-0 pb-[28px] right-0 top-0" data-name="IconSection">
      <IconOuterRing />
    </div>
  );
}

function TitleSection() {
  return (
    <div className="absolute content-stretch flex flex-col items-center left-0 pb-[12px] right-0 top-[154px]" data-name="TitleSection">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[33px] relative shrink-0 text-[#17171a] text-[22px] text-center w-full">你的职业档案已建立！</p>
    </div>
  );
}

function DescSection() {
  return (
    <div className="[word-break:break-word] absolute content-stretch flex flex-col font-['Noto_Sans_SC:Regular',sans-serif] font-normal gap-[4px] items-center leading-[20px] left-0 pb-[24px] px-[4px] right-0 text-[#68686f] text-[13px] text-center top-[199px]" data-name="DescSection">
      <p className="relative shrink-0 w-full">Careerly 已经从你的简历中认识了你的职业经历</p>
      <p className="relative shrink-0 w-full">这将成为你之后查看职业变化的起点。</p>
    </div>
  );
}

function IndexBadge() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center relative rounded-[99px] shrink-0 size-[28px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(91, 124, 246, 0.125) 0%, rgba(167, 123, 230, 0.125) 100%)" }} data-name="IndexBadge">
      <p className="[word-break:break-word] bg-clip-text font-['Roboto:Bold',sans-serif] font-bold leading-[14px] relative shrink-0 text-[11px] text-[transparent] text-center whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100', backgroundImage: "linear-gradient(116.56505117707799deg, rgb(91, 124, 246) 0%, rgb(167, 123, 230) 100%)" }}>
        1
      </p>
    </div>
  );
}

function StatusDot() {
  return <div className="bg-[#4caf7d] relative rounded-[3px] shrink-0 size-[6px]" data-name="StatusDot" />;
}

function StatusRow() {
  return (
    <div className="content-stretch flex gap-[4px] items-center relative shrink-0" data-name="StatusRow">
      <StatusDot />
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[16px] relative shrink-0 text-[#4caf7d] text-[11px] whitespace-nowrap">已识别你的职业经历</p>
    </div>
  );
}

function CardLabelGroup() {
  return (
    <div className="content-stretch flex flex-col gap-[2px] items-start relative shrink-0" data-name="CardLabelGroup">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] relative shrink-0 text-[#17171a] text-[14px] whitespace-nowrap">工作经历</p>
      <StatusRow />
    </div>
  );
}

function CardLeft() {
  return (
    <div className="content-stretch flex gap-[10px] items-center relative shrink-0" data-name="CardLeft">
      <IndexBadge />
      <CardLabelGroup />
    </div>
  );
}

function CardRight() {
  return (
    <div className="[word-break:break-word] content-stretch flex font-bold gap-[2px] items-baseline relative shrink-0 whitespace-nowrap" data-name="CardRight">
      <p className="font-['Roboto:Bold',sans-serif] leading-[32px] relative shrink-0 text-[#17171a] text-[26px]" style={{ fontVariationSettings: '"wdth" 100' }}>
        4
      </p>
      <p className="font-['Noto_Sans_SC:Bold',sans-serif] leading-[21px] relative shrink-0 text-[#242429] text-[14px]">段</p>
    </div>
  );
}

function Frame() {
  return (
    <div className="content-stretch flex items-center justify-between py-[9px] relative shrink-0 w-[315.56px]">
      <CardLeft />
      <CardRight />
    </div>
  );
}

function IndexBadge1() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center relative rounded-[99px] shrink-0 size-[28px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(91, 124, 246, 0.125) 0%, rgba(167, 123, 230, 0.125) 100%)" }} data-name="IndexBadge">
      <p className="[word-break:break-word] bg-clip-text font-['Roboto:Bold',sans-serif] font-bold leading-[14px] relative shrink-0 text-[11px] text-[transparent] text-center whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100', backgroundImage: "linear-gradient(116.56505117707799deg, rgb(91, 124, 246) 0%, rgb(167, 123, 230) 100%)" }}>
        2
      </p>
    </div>
  );
}

function StatusDot1() {
  return <div className="bg-[#4caf7d] relative rounded-[3px] shrink-0 size-[6px]" data-name="StatusDot" />;
}

function StatusRow1() {
  return (
    <div className="content-stretch flex gap-[4px] items-center relative shrink-0" data-name="StatusRow">
      <StatusDot1 />
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[16px] relative shrink-0 text-[#4caf7d] text-[11px] whitespace-nowrap">已整理你的项目经验</p>
    </div>
  );
}

function CardLabelGroup1() {
  return (
    <div className="content-stretch flex flex-col gap-[2px] items-start relative shrink-0" data-name="CardLabelGroup">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] relative shrink-0 text-[#17171a] text-[14px] whitespace-nowrap">项目经历</p>
      <StatusRow1 />
    </div>
  );
}

function CardLeft1() {
  return (
    <div className="content-stretch flex gap-[10px] items-center relative shrink-0" data-name="CardLeft">
      <IndexBadge1 />
      <CardLabelGroup1 />
    </div>
  );
}

function CardRight1() {
  return (
    <div className="[word-break:break-word] content-stretch flex font-bold gap-[2px] items-baseline relative shrink-0 whitespace-nowrap" data-name="CardRight">
      <p className="font-['Roboto:Bold',sans-serif] leading-[32px] relative shrink-0 text-[#17171a] text-[26px]" style={{ fontVariationSettings: '"wdth" 100' }}>
        6
      </p>
      <p className="font-['Noto_Sans_SC:Bold',sans-serif] leading-[21px] relative shrink-0 text-[#242429] text-[14px]">个</p>
    </div>
  );
}

function Frame1() {
  return (
    <div className="content-stretch flex items-center justify-between py-[9px] relative shrink-0 w-[315.56px]">
      <CardLeft1 />
      <CardRight1 />
    </div>
  );
}

function IndexBadge2() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center relative rounded-[99px] shrink-0 size-[28px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(91, 124, 246, 0.125) 0%, rgba(167, 123, 230, 0.125) 100%)" }} data-name="IndexBadge">
      <p className="[word-break:break-word] bg-clip-text font-['Roboto:Bold',sans-serif] font-bold leading-[14px] relative shrink-0 text-[11px] text-[transparent] text-center whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100', backgroundImage: "linear-gradient(116.56505117707799deg, rgb(91, 124, 246) 0%, rgb(167, 123, 230) 100%)" }}>
        3
      </p>
    </div>
  );
}

function StatusDot2() {
  return <div className="bg-[#4caf7d] relative rounded-[3px] shrink-0 size-[6px]" data-name="StatusDot" />;
}

function StatusRow2() {
  return (
    <div className="content-stretch flex gap-[4px] items-center relative shrink-0" data-name="StatusRow">
      <StatusDot2 />
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[16px] relative shrink-0 text-[#4caf7d] text-[11px] whitespace-nowrap">已提取你的职业能力与技能</p>
    </div>
  );
}

function CardLabelGroup2() {
  return (
    <div className="content-stretch flex flex-col gap-[2px] items-start relative shrink-0" data-name="CardLabelGroup">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] relative shrink-0 text-[#17171a] text-[14px] whitespace-nowrap">能力与技能</p>
      <StatusRow2 />
    </div>
  );
}

function CardLeft2() {
  return (
    <div className="content-stretch flex gap-[10px] items-center relative shrink-0" data-name="CardLeft">
      <IndexBadge2 />
      <CardLabelGroup2 />
    </div>
  );
}

function CardRight2() {
  return (
    <div className="[word-break:break-word] content-stretch flex font-bold gap-[2px] items-baseline relative shrink-0 whitespace-nowrap" data-name="CardRight">
      <p className="font-['Roboto:Bold',sans-serif] leading-[32px] relative shrink-0 text-[#17171a] text-[26px]" style={{ fontVariationSettings: '"wdth" 100' }}>
        12
      </p>
      <p className="font-['Noto_Sans_SC:Bold',sans-serif] leading-[21px] relative shrink-0 text-[#242429] text-[14px]">项</p>
    </div>
  );
}

function Frame2() {
  return (
    <div className="content-stretch flex items-center justify-between py-[9px] relative shrink-0 w-[315.56px]">
      <CardLeft2 />
      <CardRight2 />
    </div>
  );
}

function IndexBadge3() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center relative rounded-[99px] shrink-0 size-[28px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(91, 124, 246, 0.125) 0%, rgba(167, 123, 230, 0.125) 100%)" }} data-name="IndexBadge">
      <p className="[word-break:break-word] bg-clip-text font-['Roboto:Bold',sans-serif] font-bold leading-[0] relative shrink-0 text-[0px] text-[transparent] text-center whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100', backgroundImage: "linear-gradient(116.56505117707799deg, rgb(91, 124, 246) 0%, rgb(167, 123, 230) 100%)" }}>
        <span className="leading-[14px] text-[11px]">4</span>
        <span className="leading-[14px] text-[10px]">{` `}</span>
      </p>
    </div>
  );
}

function StatusDot3() {
  return <div className="bg-[#4caf7d] relative rounded-[3px] shrink-0 size-[6px]" data-name="StatusDot" />;
}

function StatusRow3() {
  return (
    <div className="content-stretch flex gap-[4px] items-center relative shrink-0" data-name="StatusRow">
      <StatusDot3 />
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[16px] relative shrink-0 text-[#4caf7d] text-[11px] whitespace-nowrap">已提取你的职业能力与技能</p>
    </div>
  );
}

function CardLabelGroup3() {
  return (
    <div className="content-stretch flex flex-col gap-[2px] items-start relative shrink-0" data-name="CardLabelGroup">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] relative shrink-0 text-[#17171a] text-[14px] whitespace-nowrap">{` 获奖经历`}</p>
      <StatusRow3 />
    </div>
  );
}

function CardLeft3() {
  return (
    <div className="content-stretch flex gap-[10px] items-center relative shrink-0" data-name="CardLeft">
      <IndexBadge3 />
      <CardLabelGroup3 />
    </div>
  );
}

function CardRight3() {
  return (
    <div className="[word-break:break-word] content-stretch flex font-bold gap-[2px] items-baseline relative shrink-0 whitespace-nowrap" data-name="CardRight">
      <p className="font-['Roboto:Bold',sans-serif] leading-[32px] relative shrink-0 text-[#17171a] text-[26px]" style={{ fontVariationSettings: '"wdth" 100' }}>
        5
      </p>
      <p className="font-['Noto_Sans_SC:Bold',sans-serif] leading-[21px] relative shrink-0 text-[#242429] text-[14px]">项</p>
    </div>
  );
}

function Frame3() {
  return (
    <div className="content-stretch flex items-center justify-between py-[9px] relative shrink-0 w-[315.56px]">
      <CardLeft3 />
      <CardRight3 />
    </div>
  );
}

function Card() {
  return (
    <div className="absolute backdrop-blur-[24px] bg-[rgba(255,255,255,0.68)] border-[1.217px] border-[rgba(255,255,255,0.55)] border-solid content-stretch flex flex-col items-start left-0 p-[20px] right-0 rounded-[24px] shadow-[0px_8px_32px_0px_rgba(79,126,245,0.08)] top-[267px]" data-name="Card">
      <Frame />
      <Frame1 />
      <Frame2 />
      <Frame3 />
    </div>
  );
}

function Flag() {
  return (
    <div className="relative shrink-0 size-[14px]" data-name="flag">
      <svg className="absolute block inset-0 size-full" fill="none" height="14" preserveAspectRatio="none" viewBox="0 0 14 14" width="14">
        <g id="flag">
          <path d={svgPaths.pdc4c6c0} id="Vector" stroke="url(#paint0_linear_0_4)" strokeLinecap="round" strokeWidth="2" />
        </g>
        <defs>
          <linearGradient gradientUnits="userSpaceOnUse" id="paint0_linear_0_4" x1="2.3338" x2="13.7164" y1="1.1662" y2="10.2706">
            <stop stopColor="#5B7CF6" />
            <stop offset="1" stopColor="#A77BE6" />
          </linearGradient>
        </defs>
      </svg>
    </div>
  );
}

function BaselineCard() {
  return (
    <div className="border border-[rgba(91,124,246,0.25)] border-solid content-stretch flex gap-[8px] items-center justify-center px-[16px] py-[12px] relative rounded-[12px] shrink-0 w-full" style={{ backgroundImage: "linear-gradient(172.83469126708408deg, rgba(91, 124, 246, 0.059) 0%, rgba(167, 123, 230, 0.059) 100%)" }} data-name="BaselineCard">
      <Flag />
      <p className="[word-break:break-word] bg-clip-text font-['Noto_Sans_SC:Medium',sans-serif] font-medium leading-[18px] relative shrink-0 text-[12px] text-[transparent] whitespace-nowrap" style={{ backgroundImage: "linear-gradient(175.36453657309735deg, rgb(91, 124, 246) 0%, rgb(167, 123, 230) 100%)" }}>
        你的职业基线已建立 · 这是你成长的起点
      </p>
    </div>
  );
}

function BaselineAnchor() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 py-[24px] right-0 top-[537.43px]" data-name="BaselineAnchor">
      <BaselineCard />
    </div>
  );
}

function PrimaryBtn() {
  return (
    <div className="content-stretch drop-shadow-[0px_8px_12px_rgba(91,124,246,0.31)] flex h-[52px] items-center justify-center relative rounded-[99px] shrink-0 w-full" style={{ backgroundImage: "linear-gradient(171.54930110639793deg, rgb(91, 124, 246) 0%, rgb(167, 123, 230) 100%)" }} data-name="PrimaryBtn">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[22.5px] relative shrink-0 text-[15px] text-center text-white whitespace-nowrap">进入careely</p>
    </div>
  );
}

function CtaSection() {
  return (
    <div className="absolute content-stretch flex flex-col h-[93.567px] items-start justify-between left-0 right-0 top-[629.43px]" data-name="CTASection">
      <PrimaryBtn />
    </div>
  );
}

function PageContent() {
  return (
    <div className="flex-[1_0_0] min-h-px relative w-full" data-name="PageContent">
      <IconSection />
      <TitleSection />
      <DescSection />
      <Card />
      <BaselineAnchor />
      <CtaSection />
    </div>
  );
}

function Container6() {
  return <div className="absolute h-[7px] left-[-4px] rounded-[40822700px] top-[0.01px] w-[200px]" style={{ backgroundImage: "linear-gradient(177.99546596789412deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container" />;
}

function Container5() {
  return (
    <div className="-translate-x-1/2 absolute bg-[rgba(79,126,245,0.12)] h-[7px] left-[calc(50%-1.74px)] overflow-clip rounded-[40822700px] top-[16.24px] w-[196px]" data-name="Container">
      <Container6 />
    </div>
  );
}

function Container4() {
  return (
    <div className="content-stretch flex flex-col h-[810px] items-start overflow-clip px-[20px] py-[40px] relative shrink-0 w-[390px]" data-name="Container">
      <PageContent />
      <Container5 />
    </div>
  );
}

function Container3() {
  return (
    <div className="content-stretch flex flex-[810.491_0_0] items-center min-h-px overflow-clip relative w-full" data-name="Container">
      <Container4 />
    </div>
  );
}

function Container() {
  return (
    <div className="content-stretch flex flex-col h-[843.986px] items-start max-h-[844px] max-w-[390px] overflow-clip relative shrink-0 w-[390px]" style={{ backgroundImage: "linear-gradient(110.2948550978526deg, rgb(220, 233, 251) 11.492%, rgb(229, 220, 250) 46.146%, rgb(251, 233, 241) 88.517%)" }} data-name="Container">
      <Container1 />
      <Container3 />
    </div>
  );
}

function App() {
  return (
    <div className="bg-[#d2def0] content-stretch flex h-[873.526px] items-center justify-center relative shrink-0 w-[401.481px]" data-name="App">
      <Container />
    </div>
  );
}

export default function CareerlyAppInterfaceDesignCopy() {
  return (
    <div className="bg-white content-stretch flex flex-col items-start relative size-full" data-name="Careerly App Interface Design (Copy)">
      <App />
    </div>
  );
}