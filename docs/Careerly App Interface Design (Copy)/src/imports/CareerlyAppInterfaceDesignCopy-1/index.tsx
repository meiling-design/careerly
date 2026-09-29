import svgPaths from "./svg-cygbk88lf2";

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
        <g clipPath="url(#clip0_0_8)" id="Icon">
          <path d={svgPaths.p5b1c2f0} fill="#6B7280" id="Vector" />
          <path d={svgPaths.pfa93380} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p2cd646f0} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p10337c00} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_8">
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
        <g clipPath="url(#clip0_0_4)" id="Icon">
          <path d={svgPaths.p30c54b00} id="Vector" stroke="#6B7280" strokeWidth="0.999056" />
          <path d={svgPaths.p2391db00} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p20ca00c0} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_4">
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

function Container6() {
  return <div className="relative rounded-[99px] shadow-[0px_20px_48px_0px_rgba(79,126,245,0.35)] shrink-0 size-[141px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container" />;
}

function ContainerMargin() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[100.5px] pb-[32px] top-[60.5px]" data-name="Container:margin">
      <Container6 />
    </div>
  );
}

function Heading1Margin() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[99px] pb-[12px] top-[233.5px]" data-name="Heading 1:margin">
      <p className="[word-break:break-word] bg-clip-text font-['Roboto:Bold',sans-serif] font-bold leading-[60px] relative shrink-0 text-[40px] text-[transparent] text-center tracking-[-1px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100', backgroundImage: "linear-gradient(157.3801350519596deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }}>
        Careerly
      </p>
    </div>
  );
}

function Paragraph() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[0] not-italic relative shrink-0 text-[#111827] text-[22px] text-center whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[33px]">看见能力</span>
        <span className="font-['Roboto:SemiBold',sans-serif] leading-[33px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` · `}</span>
        <span className="font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[33px]">跨越</span>
        <span className="font-['Roboto:SemiBold',sans-serif] leading-[33px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` Gap`}</span>
      </p>
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="content-stretch flex flex-col h-[37px] items-center pt-[4px] relative shrink-0 w-[198px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[33px] relative shrink-0 text-[#111827] text-[22px] text-center whitespace-nowrap">记录成长</p>
    </div>
  );
}

function Container7() {
  return (
    <div className="absolute content-stretch flex flex-col h-[94px] items-start left-[72px] pb-[24px] top-[305.5px] w-[198px]" data-name="Container">
      <Paragraph />
      <Paragraph1 />
    </div>
  );
}

function PrimaryBtn() {
  return (
    <div className="absolute content-stretch drop-shadow-[0px_8px_12px_rgba(79,126,245,0.3)] flex h-[48px] items-center justify-center left-0 rounded-[99px] top-[472.5px] w-[342px]" style={{ backgroundImage: "linear-gradient(172.0106732336031deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="PrimaryBtn">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[22.5px] relative shrink-0 text-[15px] text-center text-white whitespace-nowrap">点击登录</p>
    </div>
  );
}

function Button() {
  return (
    <div className="absolute bg-white drop-shadow-[0px_4px_2px_rgba(186,185,188,0.24)] h-[48px] left-[0.26px] rounded-[99px] top-[542.23px] w-[342px]" data-name="Button">
      <p className="-translate-x-1/2 [word-break:break-word] absolute font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[19.5px] left-[171px] text-[#6b7280] text-[15px] text-center top-[14px] whitespace-nowrap">点击注册</p>
    </div>
  );
}

function Container5() {
  return (
    <div className="h-[629px] relative shrink-0 w-full" data-name="Container">
      <ContainerMargin />
      <Heading1Margin />
      <Container7 />
      <p className="-translate-x-1/2 [word-break:break-word] absolute font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[24.375px] left-[171px] text-[#6b7280] text-[15px] text-center top-[399.5px] whitespace-nowrap">你的职业成长，从看见自己开始。</p>
      <PrimaryBtn />
      <Button />
    </div>
  );
}

function Container4() {
  return (
    <div className="absolute content-stretch flex flex-col h-[810px] items-start left-0 overflow-clip pb-[40px] pt-[64px] px-[24px] right-0 top-0" style={{ backgroundImage: "linear-gradient(111.0729547452385deg, rgb(220, 233, 251) 11.492%, rgb(229, 220, 250) 46.146%, rgb(251, 233, 241) 88.517%)" }} data-name="Container">
      <Container5 />
    </div>
  );
}

function Container3() {
  return (
    <div className="flex-[810.491_0_0] min-h-px overflow-clip relative w-full" data-name="Container">
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