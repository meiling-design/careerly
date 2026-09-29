import svgPaths from "./svg-oeqiwyn8jd";

function FillShadow() {
  return (
    <div className="absolute inset-0 rounded-[34px] shadow-[1.25px_0px_0px_-0.75px_#dbdbdb,-1.25px_0px_0px_-0.75px_#dbdbdb,0px_0px_0px_0.5px_#dbdbdb,0px_8px_48px_0px_rgba(0,0,0,0.25)]" data-name="Fill + Shadow">
      <div aria-hidden className="absolute inset-0 pointer-events-none rounded-[34px]">
        <div className="absolute bg-[rgba(255,255,255,0.7)] inset-0 mix-blend-lighten rounded-[34px]" />
        <div className="absolute bg-[rgba(191,191,191,0.1)] inset-0 mix-blend-darken rounded-[34px]" />
      </div>
    </div>
  );
}

function GlassEffect() {
  return (
    <div className="absolute inset-0 pointer-events-none rounded-[34px]" data-name="Glass Effect">
      <div aria-hidden className="absolute bg-white inset-0 mix-blend-multiply rounded-[34px]" />
      <div className="absolute inset-0 rounded-[inherit] shadow-[inset_0px_40px_10px_-40px_#282828,inset_0px_-40px_10px_-40px_#282828]" />
    </div>
  );
}

function Container() {
  return <div className="bg-[rgba(209,213,219,0.8)] h-[4px] relative rounded-[40822700px] shrink-0 w-[40px]" data-name="Container" />;
}

function ContainerMargin() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-center justify-end relative shrink-0 w-full" data-name="Container:margin">
      <Container />
    </div>
  );
}

function Icon() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="Icon">
          <path d={svgPaths.p29b3cd80} id="Vector" stroke="#FF3B30" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.83283" />
        </g>
      </svg>
    </div>
  );
}

function Container1() {
  return (
    <div className="bg-[rgba(255,59,48,0.1)] content-stretch flex items-center justify-center relative rounded-[16px] shrink-0 size-[48px]" data-name="Container">
      <Icon />
    </div>
  );
}

function ContainerMargin1() {
  return (
    <div className="content-stretch flex flex-col items-center pt-[8px] relative shrink-0 w-full" data-name="Container:margin">
      <Container1 />
    </div>
  );
}

function Heading() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Heading 2">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[27px] relative shrink-0 text-[#111827] text-[18px] text-center whitespace-nowrap">确认退出登录？</p>
    </div>
  );
}

function Paragraph() {
  return (
    <div className="content-stretch flex flex-col h-[26px] items-center pt-[6px] relative shrink-0 w-[340px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[20px] relative shrink-0 text-[#6b7280] text-[13px] text-center whitespace-nowrap">退出后将返回欢迎界面，本地数据将保留。</p>
    </div>
  );
}

function Container2() {
  return (
    <div className="content-stretch flex flex-col h-[69px] items-start pt-[16px] relative shrink-0 w-[340px]" data-name="Container">
      <Heading />
      <Paragraph />
    </div>
  );
}

function Button() {
  return (
    <div className="bg-[rgba(255,59,48,0.1)] border-[1.217px] border-[rgba(255,59,48,0.2)] border-solid content-stretch flex h-[48px] items-center justify-center relative rounded-[99px] shrink-0 w-[340px]" data-name="Button">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[22.5px] relative shrink-0 text-[#ff3b30] text-[15px] text-center whitespace-nowrap">退出登录</p>
    </div>
  );
}

function Button1() {
  return (
    <div className="bg-[rgba(55,59,77,0.87)] content-stretch flex h-[48px] items-center justify-center relative rounded-[99px] shrink-0 w-[340px]" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[21px] not-italic relative shrink-0 text-[14px] text-center text-white whitespace-nowrap">取消</p>
    </div>
  );
}

function ButtonMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[10px] relative shrink-0" data-name="Button:margin">
      <Button1 />
    </div>
  );
}

function Container3() {
  return (
    <div className="content-stretch flex flex-col h-[126px] items-start pt-[20px] relative shrink-0 w-[340px]" data-name="Container">
      <Button />
      <ButtonMargin />
    </div>
  );
}

function MenuItems() {
  return (
    <div className="relative shrink-0 w-full" data-name="Menu Items">
      <div className="content-stretch flex flex-col items-center px-[16px] relative size-full">
        <ContainerMargin />
        <ContainerMargin1 />
        <Container2 />
        <Container3 />
        <div className="h-[40px] relative shrink-0 w-full" data-name="Item">
          <div className="flex flex-row items-center size-full">
            <div className="content-stretch flex gap-[6px] items-center pl-[6px] pr-[8px] relative size-full" />
          </div>
        </div>
      </div>
    </div>
  );
}

export default function Menu() {
  return (
    <div className="relative size-full" data-name="Menu">
      <div className="flex flex-col items-center size-full">
        <div className="content-stretch flex flex-col items-center py-[10px] relative size-full">
          <FillShadow />
          <GlassEffect />
          <MenuItems />
        </div>
      </div>
    </div>
  );
}